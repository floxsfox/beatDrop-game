extends RefCounted
# analysis.gd - baca lagu (decode), cari beat, dan buat not.
# V1 = pemindai 5 pita frekuensi (flux), V2 = pemindai bass berbasis waktu audio.
# Semua berat dijalankan di thread terpisah agar layar tidak macet.

const DF := [
	{"n": "Mudah", "k": 2.7, "ga": .55, "gl": .7, "ms": 1, "busy": true, "pz": .6, "hm": .85, "ap": 2.4, "mp": [1, 1, 2, 3, 3], "cc": 99.0, "brun": 24, "bgap": .9},
	{"n": "Normal", "k": 2.55, "ga": .5, "gl": .6, "ms": 2, "busy": true, "pz": .4, "hm": .9, "ap": 2.15, "mp": [0, 1, 2, 3, 4], "cc": 1.5, "brun": 12, "bgap": .9},
	{"n": "Sulit", "k": 1.8, "ga": .2, "gl": .3, "ms": 3, "busy": false, "pz": 0.0, "hm": .6, "ap": 1.55, "mp": [0, 1, 2, 3, 4], "cc": 0.0, "brun": 99, "bgap": .9}]
const V2D := [
	{"cdK": 1.8, "cdMin": .45, "thAdd": .35, "lanes": [1, 2, 3], "chord": false},
	{"cdK": 1.0, "cdMin": .15, "thAdd": 0.0, "lanes": [0, 1, 2, 3, 4], "chord": false},
	{"cdK": .8, "cdMin": .15, "thAdd": -.2, "lanes": [0, 1, 2, 3, 4], "chord": true}]
const V2_WIN := 4
const V2_LAG := 4
const V2_AHEAD := 35
const BAND_F0 := [40.0, 150.0, 400.0, 1200.0, 3500.0]
const BAND_F1 := [150.0, 400.0, 1200.0, 3500.0, 5000.0]

var progress := 0.0
var status := ""
var done := false
var failed := ""
var result := {}
var bp := PackedFloat32Array([0.0, 0.0, 0.0, 0.0, 0.0])
var mtx := Mutex.new()
var _thread: Thread

# ------------------------------------------------------------------ kontrol job
func start_job(stream: AudioStream, gen: int, dur: float) -> void:
	progress = 0.0
	status = "Membaca file…"
	done = false
	failed = ""
	result = {}
	_thread = Thread.new()
	_thread.start(_job.bind(stream, gen, dur))

func finish_job() -> void:
	if _thread != null:
		_thread.wait_to_finish()
		_thread = null

func _job(stream: AudioStream, gen: int, dur: float) -> void:
	var pcm := decode_mono(stream, dur)
	if pcm.size() < 4000:
		failed = "Gagal membaca audio dari file ini."
		done = true
		return
	var sr := float(pcm.size()) / dur
	if gen == 2:
		status = "Memindai bass…"
		result = scan_v2(pcm, sr)
	else:
		status = "Mencari beat…"
		result = scan_v1(pcm, sr)
	progress = 1.0
	done = true

# ------------------------------------------------------------------ decode ke mono 1/4 laju sampel
func decode_mono(stream: AudioStream, dur: float) -> PackedFloat32Array:
	var pb := stream.instantiate_playback()
	var out := PackedFloat32Array()
	if pb == null:
		return out
	pb.start(0.0)
	var d := 4.0
	var chunk := 16384
	var total_est := maxf(1.0, dur * AudioServer.get_mix_rate() / d)
	var empty := 0
	while true:
		var fr: PackedVector2Array = pb.mix_audio(d, chunk)
		var n := fr.size()
		if n == 0:
			empty += 1
			if empty > 3 or not pb.is_playing():
				break
			continue
		empty = 0
		var base := out.size()
		out.resize(base + n)
		for i in range(n):
			var v: Vector2 = fr[i]
			out[base + i] = (v.x + v.y) * 0.5
		progress = minf(.3, float(base + n) / total_est * .3)
		if n < chunk and not pb.is_playing():
			break
		if out.size() > int(total_est * 1.3) + 100000:
			break
	return out

# ------------------------------------------------------------------ filter biquad (RBJ, Butterworth orde 2)
func _bq(fc: float, sr: float, hp: bool) -> Array:
	var w := TAU * fc / sr
	var c := cos(w)
	var al := sin(w) / sqrt(2.0)
	var a0 := 1.0 + al
	var b0 := (((1.0 + c) if hp else (1.0 - c)) / 2.0) / a0
	var b1 := ((-(1.0 + c)) if hp else (1.0 - c)) / a0
	return [b0, b1, b0, -2.0 * c / a0, (1.0 - al) / a0]

# ------------------------------------------------------------------ V1: 5 pita frekuensi
func _band_job(pcm: PackedFloat32Array, sr: float, f0: float, f1: float, hop: int, gain: float, out: Array, idx: int) -> void:
	var hpc := _bq(f0, sr, true)
	var lpc := _bq(minf(f1, sr * .45), sr, false)
	var hb0: float = hpc[0]
	var hb1: float = hpc[1]
	var hb2: float = hpc[2]
	var ha1: float = hpc[3]
	var ha2: float = hpc[4]
	var lb0: float = lpc[0]
	var lb1: float = lpc[1]
	var lb2: float = lpc[2]
	var la1: float = lpc[3]
	var la2: float = lpc[4]
	var hz1 := 0.0
	var hz2 := 0.0
	var lz1 := 0.0
	var lz2 := 0.0
	var nh := int(pcm.size() / hop)
	var eh := PackedFloat32Array()
	eh.resize(nh)
	var s := 0
	for k in range(nh):
		var acc := 0.0
		for i in range(hop):
			var x: float = pcm[s]
			s += 1
			var y := hb0 * x + hz1
			hz1 = hb1 * x - ha1 * y + hz2
			hz2 = hb2 * x - ha2 * y
			var z := lb0 * y + lz1
			lz1 = lb1 * y - la1 * z + lz2
			lz2 = lb2 * y - la2 * z
			acc += z * z
		eh[k] = acc
		if k % 4000 == 0:
			bp[idx] = float(k) / float(maxi(1, nh))
	var nf := nh - 1
	var e := PackedFloat32Array()
	e.resize(maxi(0, nf))
	for f in range(nf):
		var rms := sqrt((eh[f] + eh[f + 1]) / (2.0 * float(hop)))
		e[f] = log(1.0 + gain * rms)
	bp[idx] = 1.0
	mtx.lock()
	out[idx] = e
	mtx.unlock()

func scan_v1(pcm: PackedFloat32Array, sr: float) -> Dictionary:
	var hop := maxi(32, roundi(sr * 512.0 / 44100.0))
	var hop_t := float(hop) / sr
	var out: Array = [null, null, null, null, null]
	var ths: Array = []
	for b in range(5):
		var nb := maxf(1.0, roundf((BAND_F1[b] - BAND_F0[b]) / 43.0))
		var gain := 362.0 / sqrt(nb)
		var t := Thread.new()
		t.start(_band_job.bind(pcm, sr, BAND_F0[b], BAND_F1[b], hop, gain, out, b))
		ths.append(t)
	while true:
		var alive := false
		var sum := 0.0
		for t2 in ths:
			if t2.is_alive():
				alive = true
		for b2 in range(5):
			sum += bp[b2]
		progress = .3 + .6 * sum / 5.0
		if not alive:
			break
		OS.delay_msec(80)
	for t3 in ths:
		t3.wait_to_finish()
	var nf: int = (out[0] as PackedFloat32Array).size()
	for b3 in range(5):
		nf = mini(nf, (out[b3] as PackedFloat32Array).size())
	var e_arr: Array = []
	for b4 in range(5):
		var src: PackedFloat32Array = out[b4]
		var cut := src.slice(0, nf)
		e_arr.append(cut)
	var res := {"gen": 1, "E": e_arr, "nF": nf, "hopT": hop_t}
	return _prep_v1(res)

func _prep_v1(a: Dictionary) -> Dictionary:
	var nf: int = a.nF
	var f_arr: Array = []
	for b in range(5):
		var e: PackedFloat32Array = a.E[b]
		var f := PackedFloat32Array()
		f.resize(nf)
		for i in range(1, nf):
			f[i] = maxf(0.0, e[i] - e[i - 1])
		f_arr.append(f)
	a["F"] = f_arr
	a["grid"] = detect_grid(f_arr, nf, a.hopT)
	return a

func restore_v1(cache: Dictionary) -> Dictionary:
	return _prep_v1(cache.duplicate())

func detect_grid(f_arr: Array, nf: int, hop_t: float) -> Dictionary:
	if nf < 200:
		return {}
	var flux := PackedFloat32Array()
	flux.resize(nf)
	for b in range(5):
		var band: PackedFloat32Array = f_arr[b]
		var mean := 0.0
		for i in range(1, nf):
			mean += band[i]
		mean /= float(maxi(1, nf - 1))
		if mean < 1e-8:
			continue
		for i in range(1, nf):
			flux[i] += minf(5.0, band[i] / mean) / 5.0
	var avg := 0.0
	for i in range(1, nf):
		avg += flux[i]
	avg /= float(maxi(1, nf - 1))
	for i in range(1, nf):
		flux[i] -= avg
	var min_lag := maxi(2, roundi((60.0 / 180.0) / hop_t))
	var max_lag := mini(int(nf / 3.0), roundi((60.0 / 55.0) / hop_t))
	if max_lag <= min_lag:
		return {}
	var best_lag := 0
	var best_score := -1.0
	for lag in range(min_lag, max_lag + 1):
		var dot := 0.0
		var aa := 0.0
		var bb := 0.0
		for i in range(lag, nf):
			var x: float = flux[i]
			var y: float = flux[i - lag]
			dot += x * y
			aa += x * x
			bb += y * y
		var score := dot / sqrt(maxf(1e-12, aa * bb))
		var adjusted := score * (1.0 - float(lag - min_lag) / float(max_lag - min_lag + 1) * .025)
		if adjusted > best_score:
			best_score = adjusted
			best_lag = lag
	if best_lag == 0 or best_score < .045:
		return {}
	var best_phase := 0
	var best_phase_score := -1e30
	for phase in range(best_lag):
		var sum := 0.0
		var count := 0
		var center := phase
		while center < nf:
			var local := -1e30
			for d in range(-2, 3):
				var i2 := center + d
				if i2 >= 1 and i2 < nf:
					local = maxf(local, flux[i2])
			if local > -1e29:
				sum += local
				count += 1
			center += best_lag
		var sc := sum / float(count) if count > 0 else -1e30
		if sc > best_phase_score:
			best_phase_score = sc
			best_phase = phase
	return {"period": best_lag * hop_t, "phase": (best_phase + 1) * hop_t, "confidence": best_score}

func align_onset(t: float, grid: Dictionary) -> float:
	if grid.is_empty() or float(grid.confidence) < .10:
		return t
	var sub: float = float(grid.period) / 4.0
	if not (sub > 0.0):
		return t
	var snapped := float(grid.phase) + roundf((t - float(grid.phase)) / sub) * sub
	return snapped if absf(snapped - t) <= .038 else t

func gen_v1(a: Dictionary, di: int, dur: float) -> Array:
	var p: Dictionary = DF[di]
	var e_arr: Array = a.E
	var f_arr: Array = a.F
	var nf: int = a.nF
	var hop_t: float = a.hopT
	var grid: Dictionary = a.grid
	var ws := 43
	var pk_k: float = p.k
	var mp: Array = p.mp
	var hm: float = p.hm
	var cand: Array = []
	for b in range(5):
		var f: PackedFloat32Array = f_arr[b]
		var e: PackedFloat32Array = e_arr[b]
		var pre := PackedFloat64Array()
		pre.resize(nf + 1)
		for i in range(nf):
			pre[i + 1] = pre[i] + f[i]
		for i in range(2, nf - 2):
			var lo := maxi(0, i - ws)
			var hi := mini(nf, i + ws + 1)
			var th: float = (pre[hi] - pre[lo]) / float(hi - lo) * pk_k + .12
			if f[i] > th and f[i] >= f[i - 1] and f[i] > f[i + 1]:
				var pk := maxf(e[i], e[i + 1])
				var j := i + 1
				var g := 0
				while j < nf and j - i < 220:
					if e[j] >= pk - .45:
						g = 0
					else:
						g += 1
						if g > 3:
							break
					j += 1
				var j0 := i
				while j0 > 0 and i - j0 < 3 and f[j0 - 1] > f[i] * .3:
					j0 -= 1
				var dn := float(j - g - i) * hop_t
				var raw_t := float(j0 + 1) * hop_t
				var t := align_onset(raw_t, grid)
				var dd := 0.0
				if dn >= hm:
					dd = minf(dn, 2.5) - .05
				cand.append({"t": t, "l": mp[b], "s": f[i] - th, "d": dd})
	cand.sort_custom(func(x, y):
		if x.t != y.t:
			return x.t < y.t
		return y.s < x.s)
	var out: Array = []
	var last := [-9.0, -9.0, -9.0, -9.0, -9.0]
	var ct := -9.0
	var cn := 0
	var ch := false
	var bz := 0.0
	var last_chord := -9.0
	var consec := 0
	var last_acc := -9.0
	var busy: bool = p.busy
	for c in cand:
		if c.t < 1.2 or c.t > dur - .85 or c.t + c.d > dur - .18:
			continue
		if busy and c.t < bz:
			continue
		var nc: bool = c.t - ct >= .05
		if nc and c.t - ct < float(p.ga):
			continue
		if not nc and (cn >= int(p.ms) or (busy and (ch or c.d > 0.0))):
			continue
		if c.t < last[c.l] + float(p.gl):
			continue
		if not nc and float(p.cc) > 0.0 and c.t - last_chord < float(p.cc):
			continue
		var gap_b: float = c.t - last_acc
		if gap_b >= float(p.bgap):
			consec = 0
		else:
			consec += 1
			if consec > int(p.brun) and gap_b < float(p.bgap):
				continue
		if nc:
			ct = c.t
			cn = 0
			ch = false
		else:
			last_chord = c.t
		cn += 1
		if c.d > 0.0:
			ch = true
			bz = c.t + c.d + float(p.pz)
		last[c.l] = c.t + c.d
		last_acc = c.t
		out.append({"t": c.t, "l": c.l, "dur": c.d})
	return out

# ------------------------------------------------------------------ V2: pemindai bass
func scan_v2(pcm: PackedFloat32Array, sr: float) -> Dictionary:
	var hop := maxi(8, roundi(sr * 128.0 / 44100.0))
	var nb := int(pcm.size() / hop)
	var lp := _bq(140.0, sr, false)
	var hpf := _bq(2500.0, sr, true)
	var p0: float = lp[0]
	var p1: float = lp[1]
	var p2: float = lp[2]
	var p3: float = lp[3]
	var p4: float = lp[4]
	var h0: float = hpf[0]
	var h1: float = hpf[1]
	var h2: float = hpf[2]
	var h3: float = hpf[3]
	var h4: float = hpf[4]
	var za1 := 0.0
	var za2 := 0.0
	var zb1 := 0.0
	var zb2 := 0.0
	var zh1 := 0.0
	var zh2 := 0.0
	var eb := PackedFloat32Array()
	eb.resize(nb)
	var eh := PackedFloat32Array()
	eh.resize(nb)
	var s := 0
	for k in range(nb):
		var sb := 0.0
		var sh := 0.0
		for i in range(hop):
			var x: float = pcm[s]
			s += 1
			var y := p0 * x + za1
			za1 = p1 * x - p3 * y + za2
			za2 = p2 * x - p4 * y
			var yb := p0 * y + zb1
			zb1 = p1 * y - p3 * yb + zb2
			zb2 = p2 * y - p4 * yb
			var yh := h0 * x + zh1
			zh1 = h1 * x - h3 * yh + zh2
			zh2 = h2 * x - h4 * yh
			sb += yb * yb
			sh += yh * yh
		eb[k] = sb
		eh[k] = sh
		if k % 6000 == 0:
			progress = .3 + .6 * float(k) / float(maxi(1, nb))
	var env := PackedFloat32Array()
	env.resize(nb)
	var bri := PackedFloat32Array()
	bri.resize(nb)
	var wb := 0.0
	var wh := 0.0
	for k in range(nb):
		wb += eb[k]
		wh += eh[k]
		if k >= V2_WIN:
			wb -= eb[k - V2_WIN]
			wh -= eh[k - V2_WIN]
		env[k] = sqrt(maxf(0.0, wb) / float(V2_WIN * hop))
		bri[k] = log((maxf(0.0, wh) + 1e-9) / (maxf(0.0, wb) + 1e-9))
	return {"gen": 2, "env": env, "bri": bri, "hopT": float(hop) / sr, "nb": nb}

func gen_v2(a: Dictionary, di: int, dur: float, th_pct: float, cd_ms: float) -> Array:
	var env: PackedFloat32Array = a.env
	var bri: PackedFloat32Array = a.bri
	var hs: float = a.hopT
	var nb := env.size()
	var P: Dictionary = V2D[di]
	var th := th_pct / 100.0
	var cd := maxf(float(P.cdMin), cd_ms / 1000.0 * float(P.cdK))
	var mult := 1.0 + th * 1.6 + float(P.thAdd)
	var rise := PackedFloat32Array()
	rise.resize(nb)
	for k in range(V2_LAG, nb):
		rise[k] = env[k] - env[k - V2_LAG]
	var pre := PackedFloat64Array()
	pre.resize(nb + 1)
	for k in range(nb):
		pre[k + 1] = pre[k] + env[k]
	var mx := 0.0
	for k in range(nb):
		if env[k] > mx:
			mx = env[k]
	var floor_v := mx * .06
	var hw := roundi(1.0 / hs)
	var cand: Array = []
	for k in range(V2_LAG + 3, nb - V2_AHEAD - 2):
		var r: float = rise[k]
		if r <= 0.0:
			continue
		var is_pk := true
		for j in range(k - 3, k + 4):
			if rise[j] > r or (rise[j] == r and j < k):
				is_pk = false
				break
		if not is_pk:
			continue
		var lo := maxi(0, k - hw)
		var hi := mini(nb, k + hw + 1)
		var m: float = (pre[hi] - pre[lo]) / float(hi - lo)
		var top := 0.0
		var rm := 0.0
		for j in range(k, k + V2_AHEAD + 1):
			if env[j] > top:
				top = env[j]
			if rise[j] > rm:
				rm = rise[j]
		if top < m * mult or top < floor_v or r < rm * .25:
			continue
		cand.append({"t": float(k - V2_WIN + 1) * hs - .002, "s": r / (m + 1e-9), "b": bri[k + 2]})
	var acc: Array = []
	for c in cand:
		if c.t < 1.2 or c.t > dur - .85:
			continue
		if acc.size() > 0:
			var l: Dictionary = acc[acc.size() - 1]
			if c.t - l.t < cd:
				if c.t - l.t > .09 and c.s > l.s * 1.5 and (acc.size() < 2 or c.t - acc[acc.size() - 2].t >= cd):
					acc[acc.size() - 1] = c
				continue
		acc.append(c)
	var ls: Array = P.lanes
	var nl := ls.size()
	var bs: Array = []
	var ss: Array = []
	for c in acc:
		bs.append(c.b)
		ss.append(c.s)
	bs.sort()
	ss.sort()
	var s_med := 0.0
	if ss.size() > 0:
		s_med = ss[ss.size() >> 1]
	var out: Array = []
	var pi := nl >> 1
	var pt := -9.0
	var dir := 1
	for c in acc:
		var dt: float = c.t - pt
		var rk := .5
		if bs.size() > 1:
			var lo2 := 0
			var hi2 := bs.size()
			while lo2 < hi2:
				var mid := (lo2 + hi2) >> 1
				if bs[mid] < c.b:
					lo2 = mid + 1
				else:
					hi2 = mid
			rk = float(lo2) / float(bs.size() - 1)
		var ti := mini(nl - 1, int(floor(rk * nl)))
		var mj := 1 if dt < .35 else 2
		var i := pi + maxi(-mj, mini(mj, ti - pi))
		if i == pi and dt < .6:
			dir = -dir
			i = pi + dir
			if i < 0 or i >= nl:
				i = pi - dir
		out.append({"t": c.t, "l": ls[i], "dur": 0.0})
		if P.chord and c.s > s_med * 2.2 and dt > .4 and nl - 1 - i != i:
			out.append({"t": c.t, "l": ls[nl - 1 - i], "dur": 0.0})
		pi = i
		pt = c.t
	return out
