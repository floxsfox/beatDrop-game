extends Control
# game_view.gd - tampilan & logika permainan beatDrop (digambar langsung, tanpa kanvas perantara)

signal pause_requested
signal finished(res)

class Note:
	var t := 0.0
	var l := 0
	var dur := 0.0
	var st := 0
	var miss := false
	var broken := false

class Part:
	var x := 0.0
	var y := 0.0
	var vx := 0.0
	var vy := 0.0
	var l := 1.0
	var c := 0
	var s := 0.0
	var ph := 0.0
	var sp := 0.0

const ACCK := [1.2, 1.0, .75]
const GRS_COL := {"F": "#8d93a6", "C": "#ffd94a", "B": "#2ee6a6", "A": "#ffb700", "S": "#ff2d55"}

var host
var SET: Dictionary = {}
var COL: Array = []
var notes: Array = []
var ni := 0
var state := "idle"
var diff := 0
var duration := 0.0
var song_name := ""
var score := 0
var combo := 0
var max_c := 0
var cnt := [0, 0, 0, 0]
var acc_s := 0.0
var hp := 100.0
var holds_done := 0
var failed := false
var parts: Array = []
var fl: Array = []
var down := [0, 0, 0, 0, 0]
var pad := [0.0, 0.0, 0.0, 0.0, 0.0]
var ptr := {}
var pop_t := -10.0
var pop_txt := ""
var pop_col := Color.WHITE
var cp := 0.0
var dsc := 0.0
var hpg := 100.0
var pul := 0.0
var cd := ""
var cd_n := 0
var cd_t := 0.0
var cd_snd := -1
var APP := 2.0
var SP := 100.0
var app_base := 2.0

var W := 960.0
var H := 540.0
var SS := 1.25
var LX := 0.0
var L := 700.0
var LW := 140.0
var HY := 380.0
var NH := 28.0
var NHt := 28.0
var HHt := 28.0
var SQ := 90.0
var RB := 60.0
var PY := 420.0
var nw := 118.0
var TK := 0.0

var player: AudioStreamPlayer
var lead_end := 0.0
var audio_started := false
var last_cur := NAN
var last_wall := 0.0
var hold_now := -3.0
var pause_wall := 0.0
var off_ms := 0.0
var fx: Control
var glow_lane: Array = []
var glow_bg: GradientTexture2D
var fnt: Font
var fnt_b: Font
var spec: AudioEffectSpectrumAnalyzerInstance
var sb_hud := StyleBoxFlat.new()
var _lay_key := ""

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process_input(true)
	player = AudioStreamPlayer.new()
	add_child(player)
	fx = Control.new()
	fx.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	fx.material = mat
	add_child(fx)
	fx.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fx.draw.connect(_draw_fx)
	sb_hud.bg_color = Color(.04, .03, .11, .62)
	sb_hud.set_corner_radius_all(16)
	sb_hud.set_border_width_all(1)
	sb_hud.border_color = Color(1, 1, 1, .12)
	glow_bg = GradientTexture2D.new()
	glow_bg.fill = GradientTexture2D.FILL_RADIAL
	glow_bg.fill_from = Vector2(.5, .5)
	glow_bg.fill_to = Vector2(1.0, .5)
	glow_bg.width = 128
	glow_bg.height = 128
	var g := Gradient.new()
	g.colors = PackedColorArray([Color(.486, .36, 1.0, .6), Color(.486, .36, 1.0, 0.0)])
	g.offsets = PackedFloat32Array([0.0, 1.0])
	glow_bg.gradient = g
	visible = false

func set_colors(cols: Array) -> void:
	COL = cols
	glow_lane.clear()
	for c in COL:
		var t := GradientTexture2D.new()
		t.fill = GradientTexture2D.FILL_RADIAL
		t.fill_from = Vector2(.5, .5)
		t.fill_to = Vector2(1.0, .5)
		t.width = 64
		t.height = 64
		var g := Gradient.new()
		g.colors = PackedColorArray([Color.WHITE, c, Color(c.r, c.g, c.b, 0.0)])
		g.offsets = PackedFloat32Array([0.0, .25, 1.0])
		t.gradient = g
		glow_lane.append(t)

# ------------------------------------------------------------------ layout
func relayout() -> void:
	W = size.x
	H = size.y
	SS = clampf(H / 430.0, .7, 1.25)
	var tlt: bool = int(SET.get("tilt", 40)) > 0
	var wmul := .94 if tlt else .74
	var hmul := 2.6 if tlt else 1.75
	var cap := 1100.0 if tlt else 760.0
	L = minf(W * wmul, minf(H * hmul, cap))
	LX = (W - L) / 2.0
	LW = L / 5.0
	HY = H - maxf(78.0, minf(150.0, H * .25))
	NH = maxf(20.0, minf(30.0, H * .065))
	nw = roundf(LW * .84)
	SQ = roundf(minf(nw * .9, minf(H * .2, 120.0)))
	RB = roundf(minf(nw * .58, H * .14))
	var ns := int(SET.get("nshape", 0))
	var hs := int(SET.get("hole", 0))
	NHt = SQ if ns == 1 else (RB if ns == 2 else NH)
	HHt = SQ if hs == 3 else (RB if hs == 2 else NH)
	PY = roundf(HY + maxf(NH + 10.0, maxf(NHt, HHt) / 2.0 + 12.0))
	TK = float(SET.get("tilt", 40)) / 100.0 * 1.5
	_set_sp()

func _set_sp() -> void:
	APP = app_base / maxf(.4, minf(2.0, float(SET.get("spd", 1.0))))
	SP = (HY + 30.0) / APP

func accK() -> float:
	return ACCK[clampi(int(SET.get("acc", 1)), 0, 2)]

# ------------------------------------------------------------------ proyeksi kamera miring
func pj(x: float, y: float) -> Vector2:
	if TK <= 0.0:
		return Vector2(x, y)
	var d := clampf((H - y) / H, 0.0, 1.0)
	var s := 1.0 / (1.0 + TK * d)
	return Vector2(W * .5 + (x - W * .5) * s, H - H * (1.0 + TK) * d * s)

func ps(y: float) -> float:
	if TK <= 0.0:
		return 1.0
	var d := clampf((H - y) / H, 0.0, 1.0)
	return 1.0 / (1.0 + TK * d)

func quad(x0: float, y0: float, x1: float, y1: float, c0: Color, c1: Color = Color(0, 0, 0, -1)) -> void:
	if c1.a < 0.0:
		c1 = c0
	var pts := PackedVector2Array([pj(x0, y0), pj(x1, y0), pj(x1, y1), pj(x0, y1)])
	draw_primitive(pts, PackedColorArray([c0, c0, c1, c1]), PackedVector2Array())

func rrect(x: float, y: float, w: float, h: float, r: float) -> PackedVector2Array:
	r = minf(r, minf(w, h) / 2.0)
	var pts := PackedVector2Array()
	var cs := [[x + w - r, y + r, -PI * .5], [x + w - r, y + h - r, 0.0], [x + r, y + h - r, PI * .5], [x + r, y + r, PI]]
	for c in cs:
		for k in range(5):
			var a: float = float(c[2]) + float(k) * (PI * .5) / 4.0
			pts.append(Vector2(float(c[0]) + cos(a) * r, float(c[1]) + sin(a) * r))
	return pts

func ngon(cx: float, cy: float, r: float, n: int) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for k in range(n):
		var a := TAU * k / n
		pts.append(Vector2(cx + cos(a) * r, cy + sin(a) * r))
	return pts

func pjp(pts: PackedVector2Array) -> PackedVector2Array:
	var out := PackedVector2Array()
	out.resize(pts.size())
	for i in range(pts.size()):
		out[i] = pj(pts[i].x, pts[i].y)
	return out

func hole_pts(a: float, y: float, w: float, h: float) -> PackedVector2Array:
	var hk := int(SET.get("hole", 0))
	if hk == 1:
		return ngon(a + w / 2.0, y + h / 2.0, minf(w, h) / 2.0, 24)
	if hk == 2:
		return PackedVector2Array([Vector2(a, y), Vector2(a + w, y), Vector2(a + w, y + h), Vector2(a, y + h)])
	if hk == 3:
		var s := minf(w, h)
		var ox := a + (w - s) / 2.0
		var oy := y + (h - s) / 2.0
		return PackedVector2Array([Vector2(ox, oy), Vector2(ox + s, oy), Vector2(ox + s, oy + s), Vector2(ox, oy + s)])
	return rrect(a, y, w, h, h * .45)

# ------------------------------------------------------------------ jam lagu
func wall_now() -> float:
	return Time.get_ticks_usec() / 1000000.0

func raw_time() -> float:
	if not audio_started:
		return wall_now() - lead_end - off_ms / 1000.0
	return player.get_playback_position() + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency() - off_ms / 1000.0

func cur_time() -> float:
	var now := wall_now()
	var raw := raw_time()
	if is_nan(last_cur):
		last_cur = raw
		last_wall = now
		return raw
	var max_step := maxf(0.0, now - last_wall) * 1.1 + .002
	var d := raw - last_cur
	if d < 0.0:
		d = 0.0
	elif d > max_step:
		d = max_step
	last_cur += d
	last_wall = now
	return last_cur

# ------------------------------------------------------------------ mulai / jeda / lanjut
func begin(stream: AudioStream, note_src: Array, di: int, dur: float, nm: String, base_app: float, bus_name: String) -> void:
	diff = di
	duration = dur
	song_name = nm
	app_base = base_app
	off_ms = float(SET.get("off", 0))
	visible = true
	fx.visible = true
	relayout()
	notes = []
	for d in note_src:
		var n := Note.new()
		n.t = d.t
		n.l = d.l
		n.dur = d.dur
		notes.append(n)
	ni = 0
	score = 0
	combo = 0
	max_c = 0
	cnt = [0, 0, 0, 0]
	acc_s = 0.0
	parts = []
	fl = []
	pop_t = -10.0
	for i in range(5):
		pad[i] = 0.0
		down[i] = 0
	ptr.clear()
	cd = ""
	hp = 100.0
	failed = false
	holds_done = 0
	dsc = 0.0
	hpg = 100.0
	cd_snd = -1
	player.stream = stream
	player.bus = bus_name
	player.stop()
	last_cur = NAN
	hold_now = -3.0
	lead_end = wall_now() + 3.0
	audio_started = false
	var bi := AudioServer.get_bus_index(bus_name)
	spec = null
	if bi >= 0:
		for e in range(AudioServer.get_bus_effect_count(bi)):
			var inst := AudioServer.get_bus_effect_instance(bi, e)
			if inst is AudioEffectSpectrumAnalyzerInstance:
				spec = inst
	state = "play"

func pause_game() -> void:
	if state != "play":
		return
	state = "pause"
	pause_wall = wall_now()
	if audio_started:
		player.stream_paused = true
	pause_requested.emit()

func resume_game() -> void:
	if state != "pause":
		return
	state = "count"
	cd_n = 3
	cd = "3"
	cd_t = 0.0
	if host != null:
		host.sfx_count()

func stop_game() -> void:
	player.stop()
	player.stream_paused = false
	state = "idle"
	visible = false
	fx.visible = false

func _resume_now() -> void:
	cd = ""
	if not audio_started:
		lead_end += wall_now() - pause_wall
	else:
		player.stream_paused = false
	last_cur = NAN
	state = "play"

# ------------------------------------------------------------------ penilaian
func judge(q: int, l: int) -> void:
	cnt[q] += 1
	combo += 1
	max_c = maxi(max_c, combo)
	cp = 1.0
	score += roundi(float([100, 200, 300][q]) * (1.0 + float(mini(combo, 100)) / 100.0))
	acc_s += [.5, .8, 1.0][q]
	hp = minf(100.0, hp + (2.0 if q == 2 else (1.0 if q == 1 else 0.0)))
	if host != null:
		host.sfx_hit(q)
	if bool(SET.get("vib", true)):
		Input.vibrate_handheld(8)
	pop_t = wall_now()
	pop_txt = ["GOOD", "GREAT", "PERFECT"][q]
	pop_col = [Color("#9e98cc"), Color("#2ee6a6"), Color("#ffd24a")][q]
	spawn(l, 14 if q > 0 else 6)

func fail_note(txt: String) -> void:
	combo = 0
	hp -= 5.0 if txt == "PATAH" else 8.0
	if host != null:
		host.sfx_miss()
	if hp <= 0.0:
		hp = 0.0
		finish(true)
		return
	pop_t = wall_now()
	pop_txt = txt
	pop_col = Color("#ff4d6d")

func spawn(l: int, n: int) -> void:
	if not bool(SET.get("parts", true)):
		return
	fluid(l, int(ceil(n / 2.0)))
	for i in range(n):
		var p := Part.new()
		p.x = LX + l * LW + LW / 2.0
		p.y = HY
		p.vx = (randf() - .5) * 340.0
		p.vy = -randf() * 320.0 - 40.0
		p.c = l
		parts.append(p)
	if parts.size() > 160:
		parts = parts.slice(parts.size() - 160)

func fluid(l: int, n: int) -> void:
	if not bool(SET.get("parts", true)):
		return
	for i in range(n):
		var p := Part.new()
		p.x = LX + l * LW + LW / 2.0 + (randf() - .5) * LW * .7
		p.y = HY + (randf() - .5) * 8.0
		p.vx = (randf() - .5) * 26.0
		p.vy = -(50.0 + randf() * 130.0)
		p.s = .3 + randf() * .7
		p.ph = randf() * 6.3
		p.sp = .55 + randf() * .8
		p.c = l
		fl.append(p)
	if fl.size() > 240:
		fl = fl.slice(fl.size() - 240)

func press(l: int) -> void:
	down[l] += 1
	pad[l] = 1.0
	if state == "play":
		fluid(l, 6)
	if state != "play":
		return
	var now := cur_time()
	var ka := accK()
	var best = null
	var bd := .2 * ka
	var i := ni
	while i < notes.size() and notes[i].t < now + .25:
		var n: Note = notes[i]
		if n.l == l and n.st == 0:
			var d := absf(n.t - now)
			if d < bd:
				bd = d
				best = n
		i += 1
	if best == null:
		return
	var q := 0
	if bd <= .07 * ka:
		q = 2
	elif bd <= .12 * ka:
		q = 1
	judge(q, l)
	best.st = 1 if best.dur > 0.0 else 2

func release(l: int) -> void:
	down[l] = maxi(0, down[l] - 1)
	if down[l] > 0 or state != "play":
		return
	var now := cur_time()
	var i := ni
	while i < notes.size() and notes[i].t < now + .25:
		var n: Note = notes[i]
		if n.l == l and n.st == 1:
			n.st = 2
			if now < n.t + n.dur - .25:
				n.broken = true
				fail_note("PATAH")
			else:
				score += 150
				holds_done += 1
				spawn(l, 12)
		i += 1

func update_play(now: float) -> void:
	var ka := accK()
	var i := ni
	while i < notes.size() and notes[i].t < now + .25:
		var n: Note = notes[i]
		if n.st == 0 and now - n.t > .2 * ka:
			n.st = 2
			n.miss = true
			cnt[3] += 1
			fail_note("MISS")
			if state != "play":
				return
		elif n.st == 1 and now >= n.t + n.dur:
			n.st = 2
			score += 150
			holds_done += 1
			combo += 1
			max_c = maxi(max_c, combo)
			spawn(n.l, 12)
		i += 1
	while ni < notes.size() and notes[ni].t + notes[ni].dur < now - (H - HY) / SP - .3:
		ni += 1
	if now > duration + .2:
		finish(false)

func finish(is_failed: bool) -> void:
	if state == "done":
		return
	state = "done"
	if is_failed:
		player.stop()
	var tot: int = cnt[0] + cnt[1] + cnt[2] + cnt[3]
	var acc := acc_s / float(tot) if tot > 0 else 0.0
	var g := "F"
	if is_failed:
		g = "F"
	elif acc >= .985 and cnt[3] == 0:
		g = "S+"
	elif acc >= .95:
		g = "S"
	elif acc >= .92:
		g = "A+"
	elif acc >= .88:
		g = "A"
	elif acc >= .83:
		g = "B+"
	elif acc >= .78:
		g = "B"
	elif acc >= .65:
		g = "C"
	res_emit(g, acc, is_failed)

func res_emit(g: String, acc: float, is_failed: bool) -> void:
	finished.emit({"grade": g, "acc": acc, "failed": is_failed, "score": score, "maxc": max_c, "cnt": cnt.duplicate(), "hp": hp, "holds": holds_done, "name": song_name, "diff": diff})

# ------------------------------------------------------------------ input sentuh
func lane_at(p: Vector2) -> int:
	var x := p.x
	if TK > 0.0:
		var d := clampf((H - p.y) / H, 0.0, 1.0)
		x = W / 2.0 + (x - W / 2.0) * (1.0 + TK * d)
	var l := int(floor((x - LX) / LW))
	return -1 if (l < 0 or l > 4) else l

func _input(ev: InputEvent) -> void:
	if state == "idle" or state == "done" or not visible:
		return
	if ev is InputEventScreenTouch:
		var p: Vector2 = ev.position
		if ev.pressed:
			if state == "play" and p.distance_to(Vector2(W - 36.0, 36.0)) < 34.0:
				pause_game()
				return
			var l := lane_at(p)
			if l < 0:
				return
			ptr[ev.index] = l
			press(l)
		else:
			if ptr.has(ev.index):
				var l2: int = ptr[ev.index]
				ptr.erase(ev.index)
				release(l2)

# ------------------------------------------------------------------ frame
func _process(delta: float) -> void:
	if not visible or state == "idle":
		return
	if size.x != W or size.y != H:
		relayout()
	var dt := minf(.05, delta)
	var now := hold_now
	if state == "play":
		if not audio_started and wall_now() >= lead_end:
			player.play()
			audio_started = true
		now = cur_time()
		hold_now = now
		update_play(now)
	elif state == "count":
		cd_t += delta
		if cd_t >= .65:
			cd_t = 0.0
			cd_n -= 1
			if cd_n > 0:
				cd = str(cd_n)
				if host != null:
					host.sfx_count()
			else:
				_resume_now()
	var p := 0.0
	if spec != null and state == "play":
		var m := spec.get_magnitude_for_frequency_range(20.0, 220.0)
		p = clampf((m.x + m.y) * .5 * 14.0, 0.0, 1.0)
	pul += (p - pul) * (1.0 - exp(-dt * 16.0))
	for l in range(5):
		pad[l] = 1.0 if down[l] > 0 else maxf(0.0, pad[l] - dt * 5.0)
		if down[l] > 0 and state == "play" and randf() < dt * 16.0:
			fluid(l, 1)
	var i := parts.size() - 1
	while i >= 0:
		var q: Part = parts[i]
		q.l -= dt * 2.2
		if q.l <= 0.0:
			parts.remove_at(i)
		else:
			q.vy += 700.0 * dt
			q.x += q.vx * dt
			q.y += q.vy * dt
		i -= 1
	var j := fl.size() - 1
	while j >= 0:
		var q2: Part = fl[j]
		q2.l -= dt * q2.sp * .9
		if q2.l <= 0.0:
			fl.remove_at(j)
		else:
			q2.ph += dt * 4.0
			q2.vy *= 1.0 - dt * .5
			q2.x += (q2.vx + sin(q2.ph) * 18.0) * dt
			q2.y += q2.vy * dt
		j -= 1
	cp = maxf(0.0, cp - dt * 6.0)
	queue_redraw()
	fx.queue_redraw()

# ------------------------------------------------------------------ gambar
func _draw() -> void:
	if state == "idle":
		return
	var c0 := Color("#0d0a26")
	var c1 := Color("#1c0b30")
	draw_polygon(PackedVector2Array([Vector2(0, 0), Vector2(W, 0), Vector2(W, H), Vector2(0, H)]), PackedColorArray([c0, c0, c1, c1]))
	var ga := .32 + pul * .7 if bool(SET.get("glow", true)) else .12
	draw_texture_rect(glow_bg, Rect2(W / 2.0 - H * .85, HY - H * .85, H * 1.7, H * 1.7), false, Color(1, 1, 1, minf(1.0, ga)))
	var now := hold_now
	if state == "play":
		now = last_cur if not is_nan(last_cur) else raw_time()
	draw_lanes()
	draw_notes(now)
	for q in parts:
		var pp: Part = q
		var s := ps(pp.y)
		var col: Color = COL[pp.c]
		draw_circle(pj(pp.x, pp.y), (2.0 + pp.l * 3.0) * s, Color(col.r, col.g, col.b, pp.l))
	draw_hud(now)

func draw_lanes() -> void:
	var ex0 := roundf(LX)
	var ex1 := roundf(LX + L)
	quad(ex0, 0.0, ex1, H, Color(.027, .02, .07, .66))
	var gl := Color(1, 1, 1, .08)
	for i in range(6):
		var gx := roundf(LX + i * LW)
		draw_line(pj(gx, H), pj(gx, 0.0), gl, 1.0)
	var hyr := roundf(HY)
	quad(ex0, hyr - 1.0, ex1, hyr + 2.0, Color(1, 1, 1, .75))
	var ph := H - PY - 8.0
	var glow_on := bool(SET.get("glow", true))
	for l in range(5):
		var la := roundf(LX + l * LW)
		var lb := roundf(LX + (l + 1) * LW)
		var col: Color = COL[l]
		var pts := pjp(hole_pts(la + roundf(LW * .08), HY - HHt / 2.0, lb - la - roundf(LW * .16), HHt))
		var cl := PackedVector2Array(pts)
		cl.append(pts[0])
		draw_polyline(cl, col, 3.0)
		quad(la + 4.0, PY, lb - 4.0, PY + ph, Color(col.r, col.g, col.b, .08))
		if glow_on and pad[l] > .01:
			var a: float = pad[l] * .4
			quad(la, HY - H * .5, lb, HY, Color(col.r, col.g, col.b, 0.0), Color(col.r, col.g, col.b, a))
			quad(la + 4.0, PY, lb - 4.0, PY + ph, Color(col.r, col.g, col.b, pad[l] * .3))
	var edge := Color(.59, .47, 1.0, .85)
	for x in [LX, LX + L]:
		draw_line(pj(x, H), pj(x, 0.0), Color(.49, .36, 1.0, .25), 7.0)
		draw_line(pj(x, H), pj(x, 0.0), edge, 2.5)

func draw_notes(now: float) -> void:
	var ns := int(SET.get("nshape", 0))
	var box := ns > 0
	var rd := minf(8.0, NHt * .14) if box else NHt * .45
	var bw := float(SQ) if ns == 1 else nw
	var i := ni
	while i < notes.size():
		var n: Note = notes[i]
		var dtn := n.t - now
		if dtn > APP + .15:
			break
		i += 1
		if n.st == 2 and not n.miss and not n.broken:
			continue
		var x := roundf(LX + n.l * LW + LW * .08)
		var dim := n.miss or n.broken
		var hold := n.st == 1
		var y := HY if hold else HY - dtn * SP
		var col: Color = COL[n.l]
		if n.dur > 0.0:
			var ye := maxf(HY - (n.t + n.dur - now) * SP, -20.0)
			var a := .12 if dim else (.75 if hold else .45)
			if y > ye:
				quad(x + nw * .2, ye, x + nw * .8, y, Color(col.r, col.g, col.b, a))
		if y < H + 20.0:
			var al := .28 if dim else 1.0
			var bx := x + (nw - bw) / 2.0 if ns == 1 else x
			var y0 := y - NHt / 2.0
			var glow := pjp(rrect(bx - 4.0, y0 - 4.0, bw + 8.0, NHt + 8.0, (rd + 3.0) if box else NHt * .6))
			draw_colored_polygon(glow, Color(col.r, col.g, col.b, .35 * al))
			var body := rrect(bx, y0, bw, NHt, rd)
			var cols := PackedColorArray()
			for p in body:
				var t := clampf((p.y - y0) / (NHt * .4), 0.0, 1.0)
				var cc := Color.WHITE.lerp(col, t)
				cols.append(Color(cc.r, cc.g, cc.b, al))
			draw_polygon(pjp(body), cols)

func fmt_num(v: int) -> String:
	var s := str(v)
	var out := ""
	var k := 0
	for i in range(s.length() - 1, -1, -1):
		out = s[i] + out
		k += 1
		if k % 3 == 0 and i > 0:
			out = "." + out
	return out

func ctext(s: String, x: float, y: float, size_px: int, col: Color) -> void:
	draw_string(fnt_b, Vector2(x - 300.0, y), s, HORIZONTAL_ALIGNMENT_CENTER, 600.0, size_px, col)

func draw_hud(now: float) -> void:
	var w := minf(220.0 * SS, L * .6)
	var x0 := LX + 8.0
	var y0 := 8.0 * SS
	dsc += (float(score) - dsc) * (1.0 - exp(-get_process_delta_time() * 10.0))
	if absf(float(score) - dsc) < 1.0:
		dsc = float(score)
	draw_style_box(sb_hud, Rect2(x0, y0, w, 66.0 * SS))
	draw_string(fnt_b, Vector2(x0 + 12.0 * SS, y0 + 29.0 * SS), fmt_num(roundi(dsc)), HORIZONTAL_ALIGNMENT_LEFT, w, int(27.0 * SS), Color.WHITE)
	var tot: int = cnt[0] + cnt[1] + cnt[2] + cnt[3]
	var accp := (acc_s / float(tot) * 100.0) if tot > 0 else 100.0
	draw_string(fnt_b, Vector2(x0, y0 + 17.0 * SS), "%.1f%%" % accp, HORIZONTAL_ALIGNMENT_RIGHT, w - 12.0 * SS, int(12.0 * SS), Color("#b7b1e6"))
	if hp > hpg:
		hpg = hp
	else:
		hpg += (hp - hpg) * (1.0 - exp(-get_process_delta_time() * 2.5))
	var bx := x0 + 32.0 * SS
	var bw := w - 46.0 * SS
	var bh := 11.0 * SS
	var by := y0 + 43.0 * SS
	var f := maxf(0.0, hp) / 100.0
	var low := hp < 30.0
	var hcol := Color("#ff4d6d") if low else Color("#ff7aa5")
	var hb := 1.0 + (.18 * absf(sin(now * 9.0)) if low else 0.0)
	var hc := Vector2(x0 + 16.0 * SS, by + bh / 2.0)
	draw_circle(hc + Vector2(-3.5, -2.0) * SS * hb, 4.6 * SS * hb, hcol)
	draw_circle(hc + Vector2(3.5, -2.0) * SS * hb, 4.6 * SS * hb, hcol)
	draw_colored_polygon(PackedVector2Array([hc + Vector2(-8.0, 0.0) * SS * hb, hc + Vector2(8.0, 0.0) * SS * hb, hc + Vector2(0.0, 9.0) * SS * hb]), hcol)
	draw_rect(Rect2(bx, by, bw, bh), Color(1, 1, 1, .1))
	if hpg > hp + .5:
		draw_rect(Rect2(bx, by, maxf(bh, bw * hpg / 100.0), bh), Color(1, 1, 1, .6))
	if f > 0.0:
		var g0 := Color("#ff4d6d") if low else Color("#2ee6a6")
		var g1 := Color("#ff9f1c") if low else Color("#3aa0ff")
		var fw := maxf(bh, bw * f)
		draw_polygon(PackedVector2Array([Vector2(bx, by), Vector2(bx + fw, by), Vector2(bx + fw, by + bh), Vector2(bx, by + bh)]), PackedColorArray([g0, g1, g1, g0]))
		draw_rect(Rect2(bx + 2.0, by + 1.5, maxf(2.0, bw * f - 4.0), bh * .34), Color(1, 1, 1, .3))
	for k in range(1, 4):
		draw_line(Vector2(bx + bw * k / 4.0, by), Vector2(bx + bw * k / 4.0, by + bh), Color(.04, .03, .11, .55), 1.5)
	draw_rect(Rect2(bx, by, bw, bh), Color(1, 1, 1, .22), false, 1.0)
	var pr := clampf(now / maxf(.1, duration), 0.0, 1.0)
	draw_rect(Rect2(LX, 0.0, L, 4.0), Color(1, 1, 1, .12))
	draw_rect(Rect2(LX, 0.0, L * pr, 4.0), Color("#ff3d81"))
	# tombol jeda
	var pc := Vector2(W - 36.0, 36.0)
	draw_circle(pc, 22.0, Color(0, 0, 0, .45))
	draw_arc(pc, 22.0, 0.0, TAU, 24, Color(1, 1, 1, .35), 2.0)
	draw_rect(Rect2(pc.x - 7.0, pc.y - 8.0, 5.0, 16.0), Color.WHITE)
	draw_rect(Rect2(pc.x + 2.0, pc.y - 8.0, 5.0, 16.0), Color.WHITE)
	if combo >= 2:
		ctext(str(combo), W / 2.0, H * .3 + 16.0 * SS, int((46.0 + cp * 12.0) * SS), Color.WHITE)
		ctext("COMBO", W / 2.0, H * .3 + 34.0 * SS, int(12.0 * SS), Color("#9e98cc"))
	var a := (wall_now() - pop_t) / .55
	if a < 1.0:
		ctext(pop_txt, W / 2.0, HY - H * .16, int((22.0 + (1.0 - a) * 8.0) * SS), Color(pop_col.r, pop_col.g, pop_col.b, 1.0 - a * a))
	if cd != "":
		ctext(cd, W / 2.0, H * .45 + 28.0 * SS, int(84.0 * SS), Color.WHITE)
	elif state == "play":
		var rc := raw_time()
		if rc < 0.0:
			var cn := mini(3, int(ceil(-rc)))
			if cn != cd_snd:
				cd_snd = cn
				if host != null:
					host.sfx_count()
			ctext(str(cn), W / 2.0, H * .45 + 28.0 * SS, int(84.0 * SS), Color(1, 1, 1, .9))
		elif cd_snd != 99:
			cd_snd = 99
			if host != null:
				host.sfx_go()

func _draw_fx() -> void:
	if state == "idle" or glow_lane.is_empty():
		return
	for q in fl:
		var p: Part = q
		var pr := pj(p.x, p.y)
		var r := (8.0 + 24.0 * p.s) * sin(minf(1.0, (1.0 - p.l) * 5.0) * 1.57) * pow(maxf(p.l, 0.0), .5) * ps(p.y) * SS
		if r < .5:
			continue
		var tex: GradientTexture2D = glow_lane[p.c]
		fx.draw_texture_rect(tex, Rect2(pr.x - r, pr.y - r, r * 2.0, r * 2.0), false, Color(1, 1, 1, minf(1.0, p.l * 1.5) * .9))
