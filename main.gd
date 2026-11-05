extends Control
# beatDrop 1.4 - versi Godot 4 (offline, bisa impor musik dari ponsel)

const WG := preload("res://widgets.gd")
const AN := preload("res://analysis.gd")
const GVS := preload("res://game_view.gd")
const VERSION := "1.4"
const SAVE_PATH := "user://beatdrop.json"
const SRATE := 22050
const TIER_COL := ["#cd7f32", "#c0c8d8", "#ffc83d", "#6fe3ff"]
const GRS := ["F", "C", "B", "B+", "A", "A+", "S", "S+"]
const GRC := {"F": "#8d93a6", "C": "#ffd94a", "B": "#2ee6a6", "A": "#ffb700", "S": "#ff2d55"}
const ACCN := ["Longgar", "Normal", "Ketat"]
const ACCK := [1.2, 1.0, .75]
const AUDIO_EXT := ["mp3", "ogg", "wav"]
const PALS := {
	"Neon": ["#ff3d81", "#ff9f1c", "#2ee6a6", "#3aa0ff", "#b36bff"],
	"Pastel": ["#ff8fb3", "#ffd166", "#8ce8c0", "#8ecae6", "#c8b6ff"],
	"Senja": ["#ff595e", "#ff924c", "#ffca3a", "#8ac926", "#1982c4"],
	"Mono": ["#f5f2ff", "#c9c4e8", "#9e98cc", "#6f6a94", "#4a4668"]}
const ACHV := [
	["main1", "Langkah Pertama", "Mainkan 1 lagu", 0, "s", "plays", 1],
	["main5", "Mulai Serius", "Mainkan 5 lagu", 0, "s", "plays", 5],
	["main10", "Rutin", "Mainkan 10 lagu", 1, "s", "plays", 10],
	["main25", "Maraton", "Mainkan 25 lagu", 2, "s", "plays", 25],
	["main50", "Legenda Panggung", "Mainkan 50 lagu", 3, "s", "plays", 50],
	["hit100", "Pemanas", "100 not kena", 0, "s", "hits", 100],
	["hit500", "Jari Lincah", "500 not kena", 0, "s", "hits", 500],
	["hit1k", "Kombo Walker", "1.000 not kena", 1, "s", "hits", 1000],
	["hit5k", "Mesin Ketuk", "5.000 not kena", 1, "s", "hits", 5000],
	["hit10k", "Badai Jari", "10.000 not kena", 2, "s", "hits", 10000],
	["hit25k", "Dewa Ritme", "25.000 not kena", 3, "s", "hits", 25000],
	["pf50", "Akurat", "50 Perfect", 0, "s", "perfects", 50],
	["pf300", "Presisi", "300 Perfect", 1, "s", "perfects", 300],
	["pf1k", "Sempurna", "1.000 Perfect", 2, "s", "perfects", 1000],
	["pf5k", "Tanpa Cela", "5.000 Perfect", 3, "s", "perfects", 5000],
	["cb25", "Kombo 25", "Capai kombo 25", 0, "s", "bestCombo", 25],
	["cb50", "Kombo 50", "Capai kombo 50", 0, "s", "bestCombo", 50],
	["cb100", "Kombo 100", "Capai kombo 100", 1, "s", "bestCombo", 100],
	["cb200", "Kombo 200", "Capai kombo 200", 2, "s", "bestCombo", 200],
	["cb300", "Kombo 300", "Capai kombo 300", 3, "s", "bestCombo", 300],
	["s1", "Bintang S", "Raih 1 nilai S", 1, "g", "S", 1],
	["s3", "Kolektor S", "Raih 3 nilai S", 2, "g", "S", 3],
	["s5", "Pemburu S", "Raih 5 nilai S", 2, "g", "S", 5],
	["s10", "Master S", "Raih 10 nilai S", 3, "g", "S", 10],
	["sp1", "Menyala!", "Raih 1 nilai S+", 2, "g", "S+", 1],
	["sp3", "Api Abadi", "Raih 3 nilai S+", 3, "g", "S+", 3],
	["fc0", "Mulus (Mudah)", "Full kombo di Mudah", 0, "fc", 0, 1],
	["fc1", "Mulus (Normal)", "Full kombo di Normal", 1, "fc", 1, 1],
	["fc2", "Mulus (Sulit)", "Full kombo di Sulit", 2, "fc", 2, 1],
	["cl0", "Tamat (Mudah)", "Selesaikan lagu Mudah", 0, "cl", 0, 1],
	["cl1", "Tamat (Normal)", "Selesaikan lagu Normal", 0, "cl", 1, 1],
	["cl2", "Tamat (Sulit)", "Selesaikan lagu Sulit", 1, "cl", 2, 1],
	["lib1", "Kolektor", "Simpan 1 lagu", 0, "s", "songs", 1],
	["lib3", "Pustakawan", "Simpan 3 lagu", 1, "s", "songs", 3],
	["lib5", "Arsiparis", "Simpan 5 lagu", 2, "s", "songs", 5],
	["col1", "Penata Gaya", "Ubah warna beat", 0, "s", "colors", 1],
	["pv1", "Penonton", "Putar pratinjau lagu", 0, "s", "previews", 1],
	["fail1", "Gagal Itu Biasa", "HP habis sekali", 0, "s", "fails", 1],
	["miss100", "Korban Not", "100 Miss total", 0, "s", "misses", 100],
	["pause1", "Istirahat Dulu", "Jeda sekali", 0, "s", "pauses", 1],
	["sync1", "Kalibrator", "Atur sinkronisasi", 0, "s", "sync", 1],
	["night1", "Begadang", "Main jam 22-04", 0, "s", "night", 1],
	["hold50", "Tahan!", "Selesaikan 50 not tahan", 1, "s", "holds", 50],
	["gr500", "Bagus Sekali", "500 Great", 0, "s", "greats", 500],
	["gr2k", "Luar Biasa", "2.000 Great", 1, "s", "greats", 2000],
	["sc10k", "Skor 10K", "Skor 10.000 sekali main", 1, "s", "maxScore", 10000],
	["sc50k", "Skor 50K", "Skor 50.000 sekali main", 2, "s", "maxScore", 50000],
	["sc100k", "Skor 100K", "Skor 100.000 sekali main", 3, "s", "maxScore", 100000],
	["acc90", "Akurasi 90", "Akurasi 90% sekali main", 1, "r", 0, .9],
	["acc95", "Akurasi 95", "Akurasi 95% sekali main", 2, "r", 0, .95],
	["acc98", "Akurasi 98", "Akurasi 98% sekali main", 3, "r", 0, .98],
	["acc100", "Tanpa Salah", "Akurasi 100% sekali main", 3, "r", 0, 1.0],
	["lowhp", "Nyaris!", "Selesai dengan HP <20%", 1, "s", "lowhp", 1],
	["alldiff", "Penjelajah", "Main semua tingkat", 1, "d", 0, 3]]

# ---------------------------------------------------------------- data
var SET := {"cols": null, "parts": true, "glow": true, "vib": true, "hole": 0, "nshape": 0, "tilt": 40, "acc": 1, "spd": 1.0, "gen": 1, "v2th": 50, "v2cd": 250, "off": 0}
var HSL: Array = []
var COL: Array = []
var stats := {}
var ach_done := {}
var SG := {}
var best := {}
var songs: Array = []
var an := AN.new()
var A := {}
var NOTES: Array = [[], [], []]
var notes_sig := ""
var sel: Dictionary = {}
var sel_stream: AudioStream
var diff := 1
var cover_cache := {}
var busy := false

# ---------------------------------------------------------------- tampilan
var font: Font
var font_b: Font
var scr := {}
var bg
var gv
var carousel
var cur_scr := ""
var back_to := "menu"
var toast_lbl: Label
var toast_tw: Tween
var perm_asked := false

# audio
var sfxp: Array = []
var sfx_i := 0
var sfxs := {}
var bgm_p: AudioStreamPlayer
var bgm_stream: AudioStreamWAV
var prev_p: AudioStreamPlayer
var prev_t := 0.0
var game_bus := "Game"
var _buf := PackedFloat32Array()
var intro_vp: VideoStreamPlayer
var intro_done := false

# referensi UI (diisi di main_ui.gd)
var U := {}

# ================================================================ util
func hc(s: String) -> Color:
	return Color(s)

func fmt_dur(sec: float) -> String:
	return "%d:%02d" % [int(sec / 60.0), int(sec) % 60]

func fmt_n(v: int) -> String:
	var s := str(v)
	var out := ""
	var k := 0
	for i in range(s.length() - 1, -1, -1):
		out = s[i] + out
		k += 1
		if k % 3 == 0 and i > 0:
			out = "." + out
	return out

func hex_to_hsl(c: Color) -> Dictionary:
	var mx := maxf(c.r, maxf(c.g, c.b))
	var mn := minf(c.r, minf(c.g, c.b))
	var l := (mx + mn) / 2.0
	var h := 0.0
	var s := 0.0
	if mx != mn:
		var d := mx - mn
		s = d / (2.0 - mx - mn) if l > .5 else d / (mx + mn)
		if mx == c.r:
			h = (c.g - c.b) / d + (6.0 if c.g < c.b else 0.0)
		elif mx == c.g:
			h = (c.b - c.r) / d + 2.0
		else:
			h = (c.r - c.g) / d + 4.0
		h *= 60.0
	return {"h": h, "s": roundf(s * 100.0), "l": roundf(l * 100.0)}

func hsl_col(o: Dictionary) -> Color:
	return WG.HueWheel.hsl2rgb(float(o.h), float(o.s) / 100.0, float(o.l) / 100.0)

func apply_colors() -> void:
	COL = []
	for o in HSL:
		COL.append(hsl_col(o))
	SET["cols"] = HSL.duplicate(true)
	if gv != null:
		gv.set_colors(COL)

# ================================================================ simpan / muat
func default_stats() -> Dictionary:
	return {"plays": 0, "hits": 0, "perfects": 0, "greats": 0, "goods": 0, "misses": 0, "bestCombo": 0, "grades": {}, "clear": [0, 0, 0], "fc": [0, 0, 0], "fails": 0, "maxScore": 0, "bestAcc": 0.0, "holds": 0, "night": 0, "lowhp": 0, "diffs": [], "songs": 0, "colors": 0, "previews": 0, "pauses": 0, "sync": 0}

func save_all() -> void:
	var d := {"set": SET, "stats": stats, "ach": ach_done.keys(), "sg": SG, "best": best, "songs": songs}
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(d))

func load_all() -> void:
	stats = default_stats()
	var pal: Array = PALS["Neon"]
	HSL = []
	for h in pal:
		HSL.append(hex_to_hsl(Color(h)))
	if FileAccess.file_exists(SAVE_PATH):
		var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
		if f != null:
			var d = JSON.parse_string(f.get_as_text())
			if typeof(d) == TYPE_DICTIONARY:
				if d.has("set") and typeof(d["set"]) == TYPE_DICTIONARY:
					for k in d["set"]:
						SET[k] = d["set"][k]
				if d.has("stats") and typeof(d["stats"]) == TYPE_DICTIONARY:
					for k in d["stats"]:
						stats[k] = d["stats"][k]
				if d.has("ach"):
					for a in d["ach"]:
						ach_done[str(a)] = true
				if d.has("sg") and typeof(d["sg"]) == TYPE_DICTIONARY:
					SG = d["sg"]
				if d.has("best") and typeof(d["best"]) == TYPE_DICTIONARY:
					best = d["best"]
				if d.has("songs") and typeof(d["songs"]) == TYPE_ARRAY:
					songs = d["songs"]
	if SET["cols"] != null and typeof(SET["cols"]) == TYPE_ARRAY and SET["cols"].size() == 5:
		HSL = []
		for o in SET["cols"]:
			HSL.append({"h": float(o["h"]), "s": float(o["s"]), "l": float(o["l"])})
	for k in ["hole", "nshape", "tilt", "acc", "gen", "v2th", "v2cd", "off"]:
		SET[k] = int(SET[k])
	SET["spd"] = float(SET["spd"])
	if int(SET["gen"]) > 2 or int(SET["gen"]) < 1:
		SET["gen"] = 1
	stats["clear"] = _int3(stats["clear"])
	stats["fc"] = _int3(stats["fc"])
	apply_colors()

func _int3(a) -> Array:
	var r := [0, 0, 0]
	if typeof(a) == TYPE_ARRAY:
		for i in range(mini(3, a.size())):
			r[i] = int(a[i])
	return r

# ================================================================ sintesis suara (offline)
func newbuf(d: float) -> void:
	_buf = PackedFloat32Array()
	_buf.resize(int(d * SRATE))

func tone(f: float, f2: float, d: float, ty: String, v: float, t0: float = 0.0) -> void:
	var n0 := int(t0 * SRATE)
	var n := int(d * SRATE)
	var ph := 0.0
	for k in range(n):
		if n0 + k >= _buf.size():
			break
		var t := float(k) / SRATE
		var fr := f
		if f2 > 0.0:
			fr = f * pow(f2 / f, t / d)
		ph += fr / SRATE
		var fp := ph - floorf(ph)
		var wv := 0.0
		if ty == "sine":
			wv = sin(TAU * ph)
		elif ty == "square":
			wv = 1.0 if fp < .5 else -1.0
		elif ty == "sawtooth":
			wv = 2.0 * fp - 1.0
		else:
			wv = 4.0 * absf(fp - .5) - 1.0
		var env := v * pow(.001 / v, t / d)
		if t < .006:
			env *= t / .006
		_buf[n0 + k] += wv * env

func noise(d: float, v: float, fc: float, t0: float = 0.0) -> void:
	var n0 := int(t0 * SRATE)
	var n := int(d * SRATE)
	var w0 := TAU * minf(fc, SRATE * .45) / SRATE
	var al := sin(w0) / 2.0
	var a0 := 1.0 + al
	var a1 := -2.0 * cos(w0)
	var a2 := 1.0 - al
	var x1 := 0.0
	var x2 := 0.0
	var y1 := 0.0
	var y2 := 0.0
	for k in range(n):
		if n0 + k >= _buf.size():
			break
		var x := randf() * 2.0 - 1.0
		var y := (al * x - al * x2 - a1 * y1 - a2 * y2) / a0
		x2 = x1
		x1 = x
		y2 = y1
		y1 = y
		var t := float(k) / SRATE
		_buf[n0 + k] += y * v * 2.0 * pow(.001 / v, t / d)

func finish_wav(loop: bool = false) -> AudioStreamWAV:
	var n := _buf.size()
	var bytes := PackedByteArray()
	bytes.resize(n * 2)
	for i in range(n):
		bytes.encode_s16(i * 2, int(clampf(_buf[i], -1.0, 1.0) * 30000.0))
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = SRATE
	w.stereo = false
	w.data = bytes
	if loop:
		w.loop_mode = AudioStreamWAV.LOOP_FORWARD
		w.loop_begin = 0
		w.loop_end = n
	return w

func render(spec: Array) -> AudioStreamWAV:
	newbuf(spec[0])
	for i in range(1, spec.size()):
		var o: Array = spec[i]
		if o[0] == "t":
			tone(o[1], o[2], o[3], o[4], o[5], o[6])
		else:
			noise(o[1], o[2], o[3], o[4])
	return finish_wav(false)

func mf(n: int) -> float:
	return 440.0 * pow(2.0, (n - 69) / 12.0)

func build_audio() -> void:
	var bi := AudioServer.get_bus_index(game_bus)
	if bi < 0:
		AudioServer.add_bus()
		bi = AudioServer.bus_count - 1
		AudioServer.set_bus_name(bi, game_bus)
		AudioServer.add_bus_effect(bi, AudioEffectSpectrumAnalyzer.new())
	for i in range(8):
		var p := AudioStreamPlayer.new()
		add_child(p)
		sfxp.append(p)
	bgm_p = AudioStreamPlayer.new()
	bgm_p.volume_db = -10.0
	add_child(bgm_p)
	prev_p = AudioStreamPlayer.new()
	prev_p.volume_db = -4.0
	add_child(prev_p)

func build_bgm() -> void:
	var bpm := 84.0
	var sp := 30.0 / bpm
	var CH := [[57, 60, 64], [53, 57, 60], [48, 52, 55], [55, 59, 62]]
	var ARP := [0, 2, 1, 2, 0, 2, 1, 2]
	newbuf(sp * 32.0)
	for stp in range(32):
		var c: Array = CH[(stp >> 3) & 3]
		var k := stp & 7
		var t0 := stp * sp
		if k == 0:
			tone(mf(c[0] - 24), 0.0, sp * 7.5, "sine", .16, t0)
			tone(mf(c[0] - 12), 0.0, sp * 7.5, "triangle", .06, t0)
		tone(mf(c[ARP[k]] + 12), 0.0, sp * 1.6, "triangle", .06, t0)
	bgm_stream = finish_wav(true)

func sfx(key: String) -> void:
	if not synth_ready or not sfxs.has(key):
		return
	var p: AudioStreamPlayer = sfxp[sfx_i % sfxp.size()]
	sfx_i += 1
	p.stream = sfxs[key]
	p.play()

func sfx_hit(q: int) -> void:
	sfx("hit" + str(q))

func sfx_miss() -> void:
	sfx("miss")

func sfx_count() -> void:
	sfx("count")

func sfx_go() -> void:
	sfx("go")

func bgm_on() -> void:
	if bgm_stream == null or bgm_p == null:
		return
	if bgm_p.stream != bgm_stream:
		bgm_p.stream = bgm_stream
	if not bgm_p.playing:
		bgm_p.play()
	bgm_p.stream_paused = false

func bgm_off() -> void:
	if bgm_p != null:
		bgm_p.stop()

# ================================================================ toast
func toast(msg: String) -> void:
	if toast_lbl == null:
		return
	toast_lbl.text = msg
	toast_lbl.modulate = Color(1, 1, 1, 1)
	toast_lbl.visible = true
	if toast_tw != null:
		toast_tw.kill()
	toast_tw = create_tween()
	toast_tw.tween_interval(2.4)
	toast_tw.tween_property(toast_lbl, "modulate:a", 0.0, .4)
	toast_tw.tween_callback(func(): toast_lbl.visible = false)

# ================================================================ izin & berkas
func has_storage_perm() -> bool:
	if OS.get_name() != "Android":
		return true
	var g := OS.get_granted_permissions()
	for p in g:
		var s := str(p)
		if s.ends_with("MANAGE_EXTERNAL_STORAGE") or s.ends_with("READ_MEDIA_AUDIO") or s.ends_with("READ_EXTERNAL_STORAGE"):
			return true
	return false

func ask_perms() -> void:
	if OS.get_name() == "Android":
		OS.request_permissions()

func root_dir() -> String:
	if OS.get_name() == "Android":
		return "/storage/emulated/0"
	var m := OS.get_system_dir(OS.SYSTEM_DIR_MUSIC)
	return m if m != "" else OS.get_environment("HOME")

func load_stream(path: String) -> AudioStream:
	if not FileAccess.file_exists(path):
		return null
	var ext := path.get_extension().to_lower()
	var bytes := FileAccess.get_file_as_bytes(path)
	if bytes.size() < 1000:
		return null
	if ext == "mp3":
		var s := AudioStreamMP3.new()
		s.data = bytes
		return s
	if ext == "ogg":
		return AudioStreamOggVorbis.load_from_buffer(bytes)
	if ext == "wav":
		return parse_wav(bytes)
	return null

func parse_wav(b: PackedByteArray) -> AudioStream:
	if b.size() < 44 or b.slice(0, 4).get_string_from_ascii() != "RIFF":
		return null
	var pos := 12
	var ch := 2
	var rate := 44100
	var bits := 16
	var data_start := -1
	var data_len := 0
	while pos + 8 <= b.size():
		var id := b.slice(pos, pos + 4).get_string_from_ascii()
		var sz := b.decode_u32(pos + 4)
		if id == "fmt ":
			var fmt_tag := b.decode_u16(pos + 8)
			ch = b.decode_u16(pos + 10)
			rate = b.decode_u32(pos + 12)
			bits = b.decode_u16(pos + 22)
			if fmt_tag != 1 and fmt_tag != 0xFFFE:
				return null
		elif id == "data":
			data_start = pos + 8
			data_len = mini(sz, b.size() - data_start)
			break
		pos += 8 + sz + (sz & 1)
	if data_start < 0 or bits != 16 or ch < 1 or ch > 2:
		return null
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = rate
	w.stereo = ch == 2
	w.data = b.slice(data_start, data_start + data_len)
	return w

func syncsafe(b: PackedByteArray, o: int) -> int:
	return ((b[o] & 0x7f) << 21) | ((b[o + 1] & 0x7f) << 14) | ((b[o + 2] & 0x7f) << 7) | (b[o + 3] & 0x7f)

func extract_cover(b: PackedByteArray) -> Image:
	if b.size() < 20 or b[0] != 73 or b[1] != 68 or b[2] != 51:
		return null
	var ver := int(b[3])
	var total := syncsafe(b, 6)
	var end := mini(10 + total, b.size())
	var pos := 10
	if (b[5] & 0x40) != 0 and pos + 4 <= end:
		var es := syncsafe(b, pos) if ver == 4 else int(b.decode_u32(pos))
		pos += es if ver == 4 else es + 4
	while pos + 10 <= end:
		if b[pos] == 0:
			break
		var fid := b.slice(pos, pos + 4).get_string_from_ascii()
		var fs := syncsafe(b, pos + 4) if ver == 4 else ((int(b[pos + 4]) << 24) | (int(b[pos + 5]) << 16) | (int(b[pos + 6]) << 8) | int(b[pos + 7]))
		var ds := pos + 10
		if fs <= 0 or ds + fs > b.size():
			break
		if fid == "APIC":
			var enc := int(b[ds])
			var p := ds + 1
			while p < ds + fs and b[p] != 0:
				p += 1
			p += 2
			if enc == 0 or enc == 3:
				while p < ds + fs and b[p] != 0:
					p += 1
				p += 1
			else:
				while p + 1 < ds + fs and not (b[p] == 0 and b[p + 1] == 0):
					p += 2
				p += 2
			if p < ds + fs:
				var ib := b.slice(p, ds + fs)
				var img := Image.new()
				var err := ERR_FILE_UNRECOGNIZED
				if ib.size() > 4 and ib[0] == 0xFF and ib[1] == 0xD8:
					err = img.load_jpg_from_buffer(ib)
				elif ib.size() > 4 and ib[0] == 0x89 and ib[1] == 0x50:
					err = img.load_png_from_buffer(ib)
				if err == OK and img.get_width() > 8:
					return img
			return null
		pos = ds + fs
	return null

func cover_path(id: String) -> String:
	return "user://covers/" + id + ".jpg"

func get_cover(id: String) -> Texture2D:
	if cover_cache.has(id):
		return cover_cache[id]
	var p := cover_path(id)
	var tex: Texture2D = null
	if FileAccess.file_exists(p):
		var img := Image.load_from_file(p)
		if img != null and img.get_width() > 8:
			tex = ImageTexture.create_from_image(img)
	cover_cache[id] = tex
	return tex

func song_by_id(id: String) -> Dictionary:
	for s in songs:
		if str(s["id"]) == id:
			return s
	return {}

func best_grade(id: String) -> String:
	if not SG.has(id):
		return ""
	var bg_i := -1
	for g in SG[id]:
		bg_i = maxi(bg_i, GRS.find(str(g)))
	return GRS[bg_i] if bg_i >= 0 else ""

func grade_col(g: String) -> Color:
	if g == "":
		return Color.WHITE
	return Color(GRC.get(g.substr(0, 1), "#ffffff"))

# ---------------------------------------------------------------- impor lagu
func import_path(path: String, quiet: bool = false) -> bool:
	var id := path.md5_text()
	if not song_by_id(id).is_empty():
		if not quiet:
			toast("Lagu ini sudah ada di pustaka.")
		return false
	var ext := path.get_extension().to_lower()
	if not AUDIO_EXT.has(ext):
		if not quiet:
			toast("Format ." + ext + " belum didukung. Pakai MP3, OGG, atau WAV.")
		return false
	var st := load_stream(path)
	if st == null:
		if not quiet:
			toast("Gagal membaca file ini.")
		return false
	var dur := st.get_length()
	if dur < 10.0:
		if not quiet:
			toast("Lagu terlalu pendek (minimal 10 detik).")
		return false
	var nm := path.get_file().get_basename()
	if ext == "mp3":
		var bytes := FileAccess.get_file_as_bytes(path)
		var img := extract_cover(bytes)
		if img != null:
			var mx := maxi(img.get_width(), img.get_height())
			if mx > 512:
				var k := 512.0 / float(mx)
				img.resize(int(img.get_width() * k), int(img.get_height() * k), Image.INTERPOLATE_BILINEAR)
			DirAccess.make_dir_recursive_absolute("user://covers")
			img.save_jpg(cover_path(id), .88)
	songs.append({"id": id, "path": path, "name": nm, "dur": dur, "added": Time.get_unix_time_from_system()})
	stats["songs"] = songs.size()
	save_all()
	return true

func remove_song(id: String) -> void:
	for i in range(songs.size()):
		if str(songs[i]["id"]) == id:
			songs.remove_at(i)
			break
	cover_cache.erase(id)
	var cp := cover_path(id)
	if FileAccess.file_exists(cp):
		DirAccess.remove_absolute(cp)
	for g in [1, 2]:
		var ap := an_path(id, g)
		if FileAccess.file_exists(ap):
			DirAccess.remove_absolute(ap)
	SG.erase(id)
	stats["songs"] = songs.size()
	save_all()
	refresh_lib()

# ---------------------------------------------------------------- cache analisis
func an_path(id: String, gen: int) -> String:
	return "user://an/" + id + "_g" + str(gen) + ".dat"

func load_an(id: String, gen: int) -> Dictionary:
	var p := an_path(id, gen)
	if not FileAccess.file_exists(p):
		return {}
	var f := FileAccess.open(p, FileAccess.READ)
	if f == null:
		return {}
	var d = f.get_var()
	if typeof(d) != TYPE_DICTIONARY or not d.has("gen"):
		return {}
	if gen == 1:
		return an.restore_v1(d)
	return d

func save_an(id: String, gen: int, a: Dictionary) -> void:
	DirAccess.make_dir_recursive_absolute("user://an")
	var f := FileAccess.open(an_path(id, gen), FileAccess.WRITE)
	if f == null:
		return
	if gen == 1:
		f.store_var({"gen": 1, "E": a["E"], "nF": a["nF"], "hopT": a["hopT"]})
	else:
		f.store_var(a)

# ---------------------------------------------------------------- analisis + pembuatan not
func ensure_analysis() -> bool:
	var gen := int(SET["gen"])
	if not A.is_empty() and int(A.get("gen", 0)) == gen and str(A.get("sid", "")) == str(sel["id"]):
		return true
	var c := load_an(str(sel["id"]), gen)
	if not c.is_empty():
		A = c
		A["sid"] = str(sel["id"])
		return true
	go("loading")
	U["load_title"].text = "Menganalisis lagu…"
	an.start_job(sel_stream, gen, float(sel["dur"]))
	while not an.done:
		U["load_bar"].value = an.progress * 100.0
		U["load_sub"].text = an.status + "  " + str(int(an.progress * 100.0)) + "%"
		await get_tree().process_frame
	an.finish_job()
	if an.failed != "":
		toast(an.failed)
		return false
	A = an.result
	A["sid"] = str(sel["id"])
	save_an(str(sel["id"]), gen, A)
	return true

func sig_now() -> String:
	return str(sel.get("id", "")) + "|" + str(SET["gen"]) + "|" + str(SET["v2th"]) + "|" + str(SET["v2cd"])

func rebuild_notes() -> void:
	var gen := int(SET["gen"])
	var dur := float(sel["dur"])
	NOTES = [[], [], []]
	for d in range(3):
		if gen == 2:
			NOTES[d] = an.gen_v2(A, d, dur, float(SET["v2th"]), float(SET["v2cd"]))
		else:
			NOTES[d] = an.gen_v1(A, d, dur)
		await get_tree().process_frame
	notes_sig = sig_now()

func open_song(id: String) -> void:
	if busy:
		return
	var sd := song_by_id(id)
	if sd.is_empty():
		return
	busy = true
	sfx("click")
	stop_preview()
	bgm_off()
	sel = sd
	sel_stream = load_stream(str(sd["path"]))
	if sel_stream == null:
		toast("File lagu tidak ditemukan. Mungkin sudah dipindah atau dihapus.")
		busy = false
		bgm_on()
		return
	A = {}
	var ok: bool = await ensure_analysis()
	if ok:
		go("loading")
		U["load_title"].text = "Menyiapkan not…"
		U["load_bar"].value = 95.0
		await rebuild_notes()
		fill_detail()
		go("detail")
		start_preview()
	else:
		go("lib")
		bgm_on()
	busy = false

func start_game() -> void:
	if busy or sel.is_empty():
		return
	busy = true
	sfx("click")
	stop_preview()
	if notes_sig != sig_now():
		var ok: bool = await ensure_analysis()
		if not ok:
			busy = false
			go("detail")
			return
		go("loading")
		U["load_title"].text = "Menyiapkan not…"
		await rebuild_notes()
	go("loading")
	U["load_title"].text = "Menyiapkan permainan…"
	U["load_bar"].value = 100.0
	U["load_sub"].text = ""
	await get_tree().create_timer(.25).timeout
	if (NOTES[diff] as Array).size() < 5:
		toast("Lagu ini menghasilkan terlalu sedikit not. Coba tingkat lain atau generator lain.")
		go("detail")
		busy = false
		return
	var gen := int(SET["gen"])
	var base := 2.0 if gen >= 2 else float(AN.DF[diff]["ap"])
	bgm_off()
	go("game")
	gv.begin(sel_stream, NOTES[diff], diff, float(sel["dur"]), str(sel["name"]), base, game_bus)
	busy = false

# ---------------------------------------------------------------- pratinjau 10 detik
func start_preview() -> void:
	if sel_stream == null:
		return
	prev_p.stream = sel_stream
	prev_p.volume_db = -4.0
	var from := minf(float(sel["dur"]) * .3, maxf(0.0, float(sel["dur"]) - 12.0))
	prev_p.play(from)
	prev_t = 10.0
	stats["previews"] = int(stats["previews"]) + 1
	check_ach(null)

func stop_preview() -> void:
	prev_t = 0.0
	if prev_p != null:
		prev_p.stop()

# ---------------------------------------------------------------- hasil, statistik, prestasi
func on_finished(r: Dictionary) -> void:
	var cnt: Array = r["cnt"]
	var g := str(r["grade"])
	var failed: bool = r["failed"]
	stats["plays"] = int(stats["plays"]) + 1
	stats["hits"] = int(stats["hits"]) + int(cnt[0]) + int(cnt[1]) + int(cnt[2])
	stats["perfects"] = int(stats["perfects"]) + int(cnt[2])
	stats["greats"] = int(stats["greats"]) + int(cnt[1])
	stats["goods"] = int(stats["goods"]) + int(cnt[0])
	stats["misses"] = int(stats["misses"]) + int(cnt[3])
	stats["bestCombo"] = maxi(int(stats["bestCombo"]), int(r["maxc"]))
	var gr: Dictionary = stats["grades"]
	gr[g] = int(gr.get(g, 0)) + 1
	var sid := str(sel["id"])
	if not SG.has(sid):
		SG[sid] = {}
	SG[sid][g] = int(SG[sid].get(g, 0)) + 1
	var dfi := int(r["diff"])
	if not failed:
		stats["clear"][dfi] = 1
		if int(cnt[3]) == 0:
			stats["fc"][dfi] = 1
	else:
		stats["fails"] = int(stats["fails"]) + 1
	stats["maxScore"] = maxi(int(stats["maxScore"]), int(r["score"]))
	stats["bestAcc"] = maxf(float(stats["bestAcc"]), float(r["acc"]))
	stats["holds"] = int(stats["holds"]) + int(r["holds"])
	var hr := int(Time.get_datetime_dict_from_system()["hour"])
	if hr >= 22 or hr < 4:
		stats["night"] = 1
	if not failed and float(r["hp"]) < 20.0:
		stats["lowhp"] = 1
	var dl: Array = stats["diffs"]
	if not dl.has(dfi):
		dl.append(dfi)
	var key := sid + "_" + str(dfi)
	var prev_best := int(best.get(key, 0))
	var new_rec := false
	if int(r["score"]) > prev_best:
		best[key] = int(r["score"])
		new_rec = prev_best > 0
	save_all()
	show_result(r, new_rec)
	if not failed:
		sfx("fanfare")
	check_ach(r)

func check_ach(r) -> void:
	var added: Array = []
	for a in ACHV:
		var id := str(a[0])
		if ach_done.has(id):
			continue
		var ok := false
		var ty := str(a[4])
		if ty == "s":
			ok = float(stats.get(str(a[5]), 0)) >= float(a[6])
		elif ty == "g":
			ok = int(stats["grades"].get(str(a[5]), 0)) >= int(a[6])
		elif ty == "fc":
			ok = int(stats["fc"][int(a[5])]) >= 1
		elif ty == "cl":
			ok = int(stats["clear"][int(a[5])]) >= 1
		elif ty == "r":
			ok = r != null and float(r["acc"]) >= float(a[6])
		elif ty == "d":
			ok = stats["diffs"].size() >= 3
		if ok:
			ach_done[id] = true
			added.append(a)
	if added.size() > 0:
		save_all()
		sfx("unlock")
		toast("Prestasi: " + str(added[0][1]) + ("  (+" + str(added.size() - 1) + " lagi)" if added.size() > 1 else ""))
		refresh_ach_count()

# ================================================================ siklus hidup
var synth_thread: Thread
var synth_ready := false
var synth_done := false
var br_path := ""
var cust_tab := 0
var cust_lane := 0
var colors_flag := false
var wheel
var dot_tex_cache := {}

func _ready() -> void:
	Engine.max_fps = 90
	Input.use_accumulated_input = false
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	font = ThemeDB.fallback_font
	var fv := FontVariation.new()
	fv.base_font = font
	fv.variation_embolden = .55
	font_b = fv
	load_all()
	bg = WG.BgFx.new()
	add_child(bg)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	gv = GVS.new()
	gv.host = self
	gv.SET = SET
	gv.fnt = font
	gv.fnt_b = font_b
	add_child(gv)
	gv.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	gv.set_colors(COL)
	gv.pause_requested.connect(on_pause)
	gv.finished.connect(on_finished)
	build_menu()
	build_lib()
	build_browser()
	build_detail()
	build_ach()
	build_cust()
	build_loading()
	build_pause()
	build_result()
	scr["game"] = Control.new()
	scr["game"].visible = false
	add_child(scr["game"])
	toast_lbl = Label.new()
	toast_lbl.visible = false
	toast_lbl.add_theme_font_override("font", font_b)
	toast_lbl.add_theme_font_size_override("font_size", 18)
	toast_lbl.add_theme_stylebox_override("normal", sbox(Color(.05, .03, .14, .92), 22, Color(1, 1, 1, .2), 1))
	toast_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(toast_lbl)
	toast_lbl.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM, Control.PRESET_MODE_MINSIZE, 28)
	toast_lbl.grow_horizontal = Control.GROW_DIRECTION_BOTH
	toast_lbl.grow_vertical = Control.GROW_DIRECTION_BEGIN
	build_audio()
	synth_thread = Thread.new()
	synth_thread.start(_synth_job)
	refresh_lib()
	refresh_ach_count()
	play_intro()

func _synth_job() -> void:
	var T := {
		"click": [.08, ["t", 900, 0, .05, "square", .1, 0]],
		"hit0": [.12, ["t", 520, 0, .08, "triangle", .22, 0]],
		"hit1": [.14, ["t", 700, 0, .1, "triangle", .24, 0], ["t", 1050, 0, .08, "sine", .1, 0.0]],
		"hit2": [.18, ["t", 880, 0, .12, "triangle", .26, 0], ["t", 1320, 0, .1, "sine", .14, 0]],
		"miss": [.2, ["t", 180, 60, .18, "sawtooth", .18, 0]],
		"count": [.15, ["t", 660, 0, .12, "sine", .22, 0]],
		"go": [.35, ["t", 990, 0, .3, "sine", .26, 0], ["t", 1320, 0, .25, "triangle", .12, 0]],
		"fanfare": [.9, ["t", 523, 0, .25, "square", .16, 0], ["t", 659, 0, .25, "square", .16, .15], ["t", 784, 0, .25, "square", .16, .3], ["t", 1047, 0, .45, "square", .18, .45]],
		"unlock": [.5, ["t", 880, 0, .15, "sine", .2, 0], ["t", 1175, 0, .3, "sine", .2, .12]]}
	var out := {}
	for k in T:
		out[k] = render(T[k])
	build_bgm()
	sfxs = out
	synth_ready = true

func _process(delta: float) -> void:
	if synth_ready and not synth_done:
		synth_done = true
		synth_thread.wait_to_finish()
		if intro_done and ["menu", "lib", "ach", "cust", "browser"].has(cur_scr):
			bgm_on()
	if prev_t > 0.0:
		prev_t -= delta
		if prev_t <= 0.0:
			prev_p.stop()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		handle_back()
	elif what == NOTIFICATION_APPLICATION_PAUSED:
		if gv != null and gv.state == "play":
			gv.pause_game()
		if bgm_p != null:
			bgm_p.stream_paused = true
		if prev_p != null:
			prev_p.stream_paused = true
	elif what == NOTIFICATION_APPLICATION_RESUMED:
		if bgm_p != null:
			bgm_p.stream_paused = false
		if prev_p != null:
			prev_p.stream_paused = false
		if cur_scr == "browser":
			browser_refresh()

func handle_back() -> void:
	match cur_scr:
		"menu":
			get_tree().quit()
		"lib", "ach", "cust":
			go("menu")
		"browser":
			go("lib")
		"detail":
			stop_preview()
			go("lib")
		"game", "pause":
			if gv.state == "play":
				gv.pause_game()
		"result":
			go("lib")
		"intro":
			end_intro()

# ================================================================ pembantu UI
func sbox(bgc: Color, rad: int = 16, border: Color = Color(0, 0, 0, 0), bw: int = 0) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bgc
	s.set_corner_radius_all(rad)
	if bw > 0:
		s.set_border_width_all(bw)
		s.border_color = border
	s.content_margin_left = 16.0
	s.content_margin_right = 16.0
	s.content_margin_top = 6.0
	s.content_margin_bottom = 6.0
	return s

func style_btn(b: Button, col: Color, tcol: Color = Color.WHITE, rad: int = 18) -> void:
	b.add_theme_stylebox_override("normal", sbox(col, rad))
	b.add_theme_stylebox_override("hover", sbox(col.lightened(.08), rad))
	b.add_theme_stylebox_override("pressed", sbox(col.darkened(.2), rad))
	b.add_theme_stylebox_override("focus", sbox(col, rad))
	b.add_theme_stylebox_override("disabled", sbox(col.darkened(.4), rad))
	for n in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_disabled_color"]:
		b.add_theme_color_override(n, tcol)
	b.add_theme_font_override("font", font_b)
	b.focus_mode = Control.FOCUS_NONE

func mk_label(par: Node, text: String, size: int = 18, col: Color = Color.WHITE, bold: bool = false, al: int = 0) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", col)
	if bold:
		l.add_theme_font_override("font", font_b)
	l.horizontal_alignment = al
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	par.add_child(l)
	return l

func mk_btn(par: Node, text: String, cb: Callable, col: Color = Color("#2b2354"), size: int = 20, minsz: Vector2 = Vector2.ZERO) -> Button:
	var b := Button.new()
	b.text = text
	b.add_theme_font_size_override("font_size", size)
	style_btn(b, col)
	b.custom_minimum_size = minsz
	b.pressed.connect(cb)
	par.add_child(b)
	return b

func new_screen(nm: String) -> Control:
	var c := Control.new()
	c.visible = false
	add_child(c)
	c.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scr[nm] = c
	return c

func hbox(par: Node, sep: int = 10) -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", sep)
	par.add_child(h)
	return h

func vbox(par: Node, sep: int = 10) -> VBoxContainer:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", sep)
	par.add_child(v)
	return v

func spacer(par: Node, w: float = 0.0, h: float = 0.0, grow: bool = false) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(w, h)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if grow:
		c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		c.size_flags_vertical = Control.SIZE_EXPAND_FILL
	par.add_child(c)
	return c

func dot_tex(r: int, col: Color) -> Texture2D:
	var key := str(r) + col.to_html()
	if dot_tex_cache.has(key):
		return dot_tex_cache[key]
	var n := r * 2 + 4
	var img := Image.create(n, n, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for y in range(n):
		for x in range(n):
			var d := Vector2(x + .5, y + .5).distance_to(Vector2(n / 2.0, n / 2.0))
			if d <= r:
				img.set_pixel(x, y, Color.WHITE if d > r - 2.0 else col)
	var t := ImageTexture.create_from_image(img)
	dot_tex_cache[key] = t
	return t

func mk_slider(par: Node, mn: float, mx: float, step: float, val: float, cb: Callable) -> HSlider:
	var s := HSlider.new()
	s.min_value = mn
	s.max_value = mx
	s.step = step
	s.value = val
	s.custom_minimum_size = Vector2(240, 36)
	s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	s.add_theme_stylebox_override("slider", sbox(Color(1, 1, 1, .14), 6))
	s.add_theme_stylebox_override("grabber_area", sbox(Color("#ff3d81"), 6))
	s.add_theme_stylebox_override("grabber_area_highlight", sbox(Color("#ff6aa0"), 6))
	var dt := dot_tex(14, Color("#ff3d81"))
	s.add_theme_icon_override("grabber", dt)
	s.add_theme_icon_override("grabber_highlight", dt)
	s.value_changed.connect(cb)
	par.add_child(s)
	return s

func set_sel_style(b: Button, on: bool, col: Color = Color("#ff3d81")) -> void:
	style_btn(b, col if on else Color("#2b2354"))

func go(nm: String) -> void:
	for k in scr:
		scr[k].visible = (k == nm)
	cur_scr = nm
	if U.has("del_box"):
		U["del_box"].visible = false
	bg.visible = not (nm == "game" or nm == "pause")
	if ["menu", "lib", "ach", "cust", "browser"].has(nm):
		if synth_done:
			bgm_on()
	elif nm == "detail":
		bgm_off()
	elif nm != "intro":
		bgm_off()

func top_bar(s: Control, title: String, back_cb: Callable, back_txt: String = "< Kembali") -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 12)
	s.add_child(h)
	h.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	h.offset_left = 16.0
	h.offset_right = -16.0
	h.offset_top = 12.0
	h.offset_bottom = 66.0
	mk_btn(h, back_txt, back_cb, Color("#2b2354"), 18, Vector2(130, 48))
	var t := mk_label(h, title, 26, Color.WHITE, true)
	t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	t.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return h

# ================================================================ intro
func play_intro() -> void:
	var s := new_screen("intro")
	var cr := ColorRect.new()
	cr.color = Color.BLACK
	s.add_child(cr)
	cr.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if not ResourceLoader.exists("res://intro.ogv"):
		end_intro()
		return
	var vs = load("res://intro.ogv")
	if vs == null:
		end_intro()
		return
	intro_vp = VideoStreamPlayer.new()
	intro_vp.stream = vs
	intro_vp.expand = true
	intro_vp.finished.connect(end_intro)
	s.add_child(intro_vp)
	intro_vp.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var tap := Button.new()
	tap.flat = true
	tap.focus_mode = Control.FOCUS_NONE
	tap.pressed.connect(end_intro)
	s.add_child(tap)
	tap.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	go("intro")
	intro_vp.play()
	get_tree().create_timer(9.0).timeout.connect(end_intro)

func end_intro() -> void:
	if intro_done:
		return
	intro_done = true
	if intro_vp != null:
		intro_vp.stop()
	go("menu")

# ================================================================ menu
func build_menu() -> void:
	var s := new_screen("menu")
	var vl := Label.new()
	vl.text = "Versi " + VERSION
	vl.add_theme_font_override("font", font_b)
	vl.add_theme_font_size_override("font_size", 15)
	vl.add_theme_color_override("font_color", Color("#cfc9ff"))
	vl.add_theme_stylebox_override("normal", sbox(Color(0, 0, 0, .45), 14, Color(1, 1, 1, .15), 1))
	vl.position = Vector2(14, 12)
	s.add_child(vl)
	var cc := CenterContainer.new()
	s.add_child(cc)
	cc.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var v := vbox(cc, 6)
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	var logo := TextureRect.new()
	logo.texture = load("res://icon.png")
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo.custom_minimum_size = Vector2(110, 110)
	v.add_child(logo)
	var tr := hbox(v, 0)
	tr.alignment = BoxContainer.ALIGNMENT_CENTER
	mk_label(tr, "Beat", 56, Color.WHITE, true)
	mk_label(tr, "Drop", 56, Color("#ff3d81"), true)
	mk_label(v, "Mainkan lagumu sendiri, ketuk mengikuti irama", 16, Color("#b7b1e6"), false, HORIZONTAL_ALIGNMENT_CENTER)
	spacer(v, 0, 8)
	var row := hbox(v, 22)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	var defs := [[0, "MAIN", "Pilih lagu dan mulai", "#ff3d81"], [1, "PRESTASI", "0 / 54 terbuka", "#ffc83d"], [2, "KUSTOM", "Warna, bentuk, efek", "#3aa0ff"]]
	for d in defs:
		var c := WG.MenuCard.new()
		c.kind = d[0]
		c.label = d[1]
		c.sub = d[2]
		c.accent = Color(d[3])
		c.fnt = font_b
		c.custom_minimum_size = Vector2(230, 190)
		row.add_child(c)
		if d[0] == 0:
			c.pressed.connect(func():
				sfx("click")
				go("lib"))
		elif d[0] == 1:
			U["ach_card"] = c
			c.pressed.connect(func():
				sfx("click")
				fill_ach()
				go("ach"))
		else:
			c.pressed.connect(func():
				sfx("click")
				fill_cust()
				go("cust"))
	spacer(v, 0, 6)
	mk_label(v, "Offline - musik diambil dari ponselmu", 13, Color(.6, .58, .8), false, HORIZONTAL_ALIGNMENT_CENTER)

func refresh_ach_count() -> void:
	if U.has("ach_card"):
		U["ach_card"].sub = "%d / %d terbuka" % [ach_done.size(), ACHV.size()]

# ================================================================ pustaka lagu
func build_lib() -> void:
	var s := new_screen("lib")
	var h := top_bar(s, "Pustaka Lagu", func():
		sfx("click")
		go("menu"))
	U["lib_count"] = mk_label(h, "", 15, Color("#b7b1e6"))
	mk_btn(h, "+ UPLOAD", ui_upload, Color("#ff3d81"), 18, Vector2(140, 48))
	carousel = WG.Carousel.new()
	carousel.fnt = font
	carousel.fnt_b = font_b
	carousel.empty_text = "Belum ada lagu.\nTekan UPLOAD untuk menambah musik dari ponselmu."
	s.add_child(carousel)
	carousel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	carousel.offset_top = 76.0
	carousel.offset_bottom = -36.0
	carousel.opened.connect(open_song)
	carousel.long_pressed.connect(confirm_delete)
	var ov := Control.new()
	ov.visible = false
	s.add_child(ov)
	ov.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var dcr := ColorRect.new()
	dcr.color = Color(0, 0, 0, .72)
	ov.add_child(dcr)
	dcr.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var dcc := CenterContainer.new()
	ov.add_child(dcc)
	dcc.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var dpc := PanelContainer.new()
	dpc.add_theme_stylebox_override("panel", sbox(Color(.08, .06, .2, .98), 22, Color(1, 1, 1, .2), 2))
	dcc.add_child(dpc)
	var dv := vbox(dpc, 14)
	U["del_lbl"] = mk_label(dv, "", 18, Color.WHITE, true, HORIZONTAL_ALIGNMENT_CENTER)
	var drow := hbox(dv, 12)
	drow.alignment = BoxContainer.ALIGNMENT_CENTER
	mk_btn(drow, "BATAL", ui_del_cancel, Color("#2b2354"), 18, Vector2(130, 46))
	mk_btn(drow, "HAPUS", ui_del_ok, Color("#ff4d6d"), 18, Vector2(130, 46))
	U["del_box"] = ov
	var hint := mk_label(s, "Geser untuk memilih - ketuk kartu tengah untuk main - tahan untuk hapus dari daftar", 13, Color(.6, .58, .8), false, HORIZONTAL_ALIGNMENT_CENTER)
	hint.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	hint.offset_top = -30.0
	hint.offset_bottom = -8.0

func refresh_lib(keep: String = "") -> void:
	if carousel == null:
		return
	var items: Array = []
	for sd in songs:
		var id := str(sd["id"])
		var g := best_grade(id)
		items.append({"id": id, "name": sd["name"], "meta": fmt_dur(float(sd["dur"])), "tex": get_cover(id), "grade": g, "gcol": grade_col(g)})
	carousel.set_items(items, keep)
	if U.has("lib_count"):
		U["lib_count"].text = "%d lagu" % songs.size()

func confirm_delete(id: String) -> void:
	var sd := song_by_id(id)
	if sd.is_empty():
		return
	U["del_id"] = id
	U["del_lbl"].text = "Hapus \"" + str(sd["name"]) + "\" dari daftar?\n(File musik di ponsel tidak dihapus)"
	U["del_box"].visible = true

# ================================================================ browser file
func build_browser() -> void:
	var s := new_screen("browser")
	var h := top_bar(s, "Pilih Musik", func():
		sfx("click")
		go("lib"))
	mk_btn(h, "Selesai", ui_browser_done, Color("#ff3d81"), 18, Vector2(110, 48))
	var body := vbox(s, 8)
	body.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	body.offset_left = 16.0
	body.offset_right = -16.0
	body.offset_top = 74.0
	body.offset_bottom = -12.0
	var row := hbox(body, 8)
	mk_btn(row, "Naik", ui_browser_up, Color("#2b2354"), 16, Vector2(70, 40))
	var qs := [["Musik", "Music"], ["Unduhan", "Download"], ["Dokumen", "Documents"], ["Telegram", "Telegram/Telegram Audio"], ["WhatsApp", "Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Audio"]]
	for q in qs:
		mk_btn(row, q[0], ui_quick.bind(str(q[0]), str(q[1])), Color("#2b2354"), 15, Vector2(0, 40))
	mk_btn(row, "Izin akses", ui_perm, Color("#3aa0ff"), 15, Vector2(0, 40))
	U["br_path"] = mk_label(body, "", 13, Color(.7, .68, .9))
	U["br_path"].clip_text = true
	var sc := ScrollContainer.new()
	sc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(sc)
	var lst := vbox(sc, 6)
	lst.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	U["br_list"] = lst
	U["br_all"] = mk_btn(body, "Tambah semua lagu di folder ini", add_folder, Color("#2ee6a6"), 17, Vector2(0, 44))
	U["br_all"].add_theme_color_override("font_color", Color("#06241a"))

func open_browser(path: String = "") -> void:
	if not perm_asked:
		perm_asked = true
		ask_perms()
	br_path = path if path != "" else root_dir()
	go("browser")
	browser_refresh()

func browser_refresh() -> void:
	var lst: VBoxContainer = U["br_list"]
	for c in lst.get_children():
		c.queue_free()
	U["br_path"].text = br_path
	var d := DirAccess.open(br_path)
	if d == null:
		var l := mk_label(lst, "Folder tidak bisa dibuka.\nTekan \"Izin akses\" lalu izinkan akses musik/penyimpanan.", 16, Color("#ffb4c8"))
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.custom_minimum_size = Vector2(500, 0)
		return
	var dirs: Array = []
	var files: Array = []
	d.list_dir_begin()
	var n := d.get_next()
	while n != "":
		if not n.begins_with("."):
			if d.current_is_dir():
				dirs.append(n)
			elif AUDIO_EXT.has(n.get_extension().to_lower()):
				files.append(n)
		n = d.get_next()
	d.list_dir_end()
	dirs.sort_custom(func(a, b): return str(a).to_lower() < str(b).to_lower())
	files.sort_custom(func(a, b): return str(a).to_lower() < str(b).to_lower())
	for dn in dirs:
		var b := mk_btn(lst, "  " + str(dn) + "  /", ui_enter.bind(str(dn)), Color("#241d48"), 17, Vector2(0, 46))
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	for fn in files:
		var full := br_path.path_join(str(fn))
		var added := not song_by_id(full.md5_text()).is_empty()
		var b2 := mk_btn(lst, str(fn) + ("   (sudah ada)" if added else ""), import_one.bind(full), Color("#3a2b6b") if not added else Color("#1b2a2a"), 16, Vector2(0, 46))
		b2.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b2.clip_text = true
	if dirs.is_empty() and files.is_empty():
		mk_label(lst, "Tidak ada folder atau file musik (MP3/OGG/WAV) di sini.", 16, Color(.7, .68, .9))
	U["br_all"].text = "Tambah semua lagu di folder ini (%d)" % files.size()
	U["br_all"].disabled = files.is_empty()

func import_one(path: String) -> void:
	if busy:
		return
	busy = true
	sfx("click")
	toast("Membaca lagu…")
	await get_tree().process_frame
	await get_tree().process_frame
	var ok := import_path(path)
	if ok:
		toast("Ditambahkan: " + path.get_file().get_basename())
		sfx("unlock")
		refresh_lib(str(path.md5_text()))
		check_ach(null)
	busy = false
	browser_refresh()

func add_folder() -> void:
	if busy:
		return
	busy = true
	sfx("click")
	var d := DirAccess.open(br_path)
	var files: Array = []
	if d != null:
		d.list_dir_begin()
		var n := d.get_next()
		while n != "":
			if not d.current_is_dir() and AUDIO_EXT.has(n.get_extension().to_lower()):
				files.append(n)
			n = d.get_next()
		d.list_dir_end()
	files.sort()
	var added := 0
	for i in range(files.size()):
		toast("Menambah %d / %d …" % [i + 1, files.size()])
		await get_tree().process_frame
		if import_path(br_path.path_join(str(files[i])), true):
			added += 1
	refresh_lib()
	check_ach(null)
	toast("%d lagu ditambahkan" % added if added > 0 else "Tidak ada lagu baru.")
	busy = false
	browser_refresh()

# ================================================================ detail lagu
func build_detail() -> void:
	var s := new_screen("detail")
	top_bar(s, "", func():
		sfx("click")
		stop_preview()
		go("lib"))
	var body := hbox(s, 22)
	body.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	body.offset_left = 20.0
	body.offset_right = -20.0
	body.offset_top = 74.0
	body.offset_bottom = -14.0
	var left := vbox(body, 8)
	left.custom_minimum_size = Vector2(250, 0)
	var cv := TextureRect.new()
	cv.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	cv.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	cv.custom_minimum_size = Vector2(230, 230)
	cv.clip_contents = true
	U["d_cover"] = cv
	var pc := PanelContainer.new()
	pc.add_theme_stylebox_override("panel", sbox(Color(1, 1, 1, .08), 22, Color(1, 1, 1, .25), 2))
	pc.add_child(cv)
	left.add_child(pc)
	var nm := mk_label(left, "", 22, Color.WHITE, true)
	nm.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	nm.custom_minimum_size = Vector2(240, 0)
	nm.max_lines_visible = 2
	U["d_name"] = nm
	U["d_meta"] = mk_label(left, "", 15, Color("#b7b1e6"))
	U["d_hist"] = mk_label(left, "", 14, Color("#cfc9ff"))
	var right := vbox(body, 10)
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mk_label(right, "TINGKAT KESULITAN", 13, Color("#9e98cc"), true)
	var dr := hbox(right, 8)
	var dbs: Array = []
	for i in range(3):
		var b := Button.new()
		b.add_theme_font_size_override("font_size", 17)
		b.custom_minimum_size = Vector2(0, 58)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.pressed.connect(set_diff.bind(i))
		dr.add_child(b)
		dbs.append(b)
	U["d_diff"] = dbs
	mk_label(right, "AKURASI PENILAIAN", 13, Color("#9e98cc"), true)
	var ar := hbox(right, 8)
	var abs_: Array = []
	for i in range(3):
		var b := Button.new()
		b.text = ACCN[i]
		b.add_theme_font_size_override("font_size", 16)
		b.custom_minimum_size = Vector2(0, 42)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.pressed.connect(set_acc.bind(i))
		ar.add_child(b)
		abs_.append(b)
	U["d_acc"] = abs_
	U["d_accv"] = mk_label(right, "", 13, Color("#b7b1e6"))
	var sr := hbox(right, 8)
	mk_label(sr, "Kecepatan", 15, Color.WHITE, true).custom_minimum_size = Vector2(110, 0)
	U["d_spd"] = mk_slider(sr, .5, 2.0, .05, float(SET["spd"]), on_spd)
	U["d_spdv"] = mk_label(sr, "", 15, Color("#ffd24a"), true)
	U["d_spdv"].custom_minimum_size = Vector2(60, 0)
	var yr := hbox(right, 8)
	mk_label(yr, "Sinkron (ms)", 15, Color.WHITE, true).custom_minimum_size = Vector2(110, 0)
	U["d_off"] = mk_slider(yr, -300.0, 300.0, 5.0, float(SET["off"]), on_off)
	U["d_offv"] = mk_label(yr, "", 15, Color("#ffd24a"), true)
	U["d_offv"].custom_minimum_size = Vector2(60, 0)
	spacer(right, 0, 4, true)
	var go_b := mk_btn(right, "MULAI", start_game, Color("#ff3d81"), 28, Vector2(0, 62))
	U["d_start"] = go_b

func set_diff(i: int) -> void:
	sfx("click")
	diff = i
	paint_detail()

func set_acc(i: int) -> void:
	sfx("click")
	SET["acc"] = i
	save_all()
	paint_detail()

func on_spd(v: float) -> void:
	SET["spd"] = snappedf(v, .05)
	U["d_spdv"].text = "%.2fx" % float(SET["spd"])
	save_all()

func on_off(v: float) -> void:
	SET["off"] = int(v)
	U["d_offv"].text = "%d" % int(v)
	stats["sync"] = 1
	save_all()
	check_ach(null)

func fill_detail() -> void:
	var tex := get_cover(str(sel["id"]))
	U["d_cover"].texture = tex
	U["d_name"].text = str(sel["name"])
	U["d_meta"].text = "Durasi " + fmt_dur(float(sel["dur"]))
	paint_detail()

func paint_detail() -> void:
	var id := str(sel.get("id", ""))
	var dbs: Array = U["d_diff"]
	for i in range(3):
		var b: Button = dbs[i]
		b.text = "%s\n%d not" % [AN.DF[i]["n"], (NOTES[i] as Array).size()]
		set_sel_style(b, i == diff)
	var abs_: Array = U["d_acc"]
	for i in range(3):
		set_sel_style(abs_[i], i == int(SET["acc"]), Color("#3aa0ff"))
	U["d_accv"].text = "Perfect +/- %d ms" % roundi(70.0 * float(ACCK[int(SET["acc"])]))
	U["d_spd"].set_value_no_signal(float(SET["spd"]))
	U["d_spdv"].text = "%.2fx" % float(SET["spd"])
	U["d_off"].set_value_no_signal(float(SET["off"]))
	U["d_offv"].text = "%d" % int(SET["off"])
	var hist := ""
	if SG.has(id):
		var parts: Array = []
		for g in GRS:
			if SG[id].has(g):
				parts.append("%s x%d" % [g, int(SG[id][g])])
		hist = "Riwayat: " + ", ".join(parts)
	var bk := id + "_" + str(diff)
	if best.has(bk):
		hist += ("\n" if hist != "" else "") + "Rekor: " + fmt_n(int(best[bk]))
	U["d_hist"].text = hist if hist != "" else "Belum pernah dimainkan"

# ================================================================ prestasi
func build_ach() -> void:
	var s := new_screen("ach")
	top_bar(s, "Prestasi", func():
		sfx("click")
		go("menu"))
	var sc := ScrollContainer.new()
	s.add_child(sc)
	sc.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	sc.offset_left = 16.0
	sc.offset_right = -16.0
	sc.offset_top = 74.0
	sc.offset_bottom = -10.0
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var g := GridContainer.new()
	g.columns = 2
	g.add_theme_constant_override("h_separation", 10)
	g.add_theme_constant_override("v_separation", 10)
	g.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sc.add_child(g)
	U["ach_grid"] = g

func fill_ach() -> void:
	var g: GridContainer = U["ach_grid"]
	for c in g.get_children():
		c.queue_free()
	for a in ACHV:
		var got := ach_done.has(str(a[0]))
		var pc := PanelContainer.new()
		pc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		pc.custom_minimum_size = Vector2(0, 68)
		var tc := Color(TIER_COL[int(a[3])])
		pc.add_theme_stylebox_override("panel", sbox(Color(.1, .08, .22, .9) if got else Color(.06, .05, .13, .8), 16, tc if got else Color(1, 1, 1, .08), 2))
		var v := vbox(pc, 2)
		mk_label(v, str(a[1]) + ("" if got else "  (terkunci)"), 17, Color.WHITE if got else Color(.55, .53, .7), true)
		mk_label(v, str(a[2]), 13, Color("#b7b1e6") if got else Color(.45, .43, .6))
		g.add_child(pc)

# ================================================================ loading
func build_loading() -> void:
	var s := new_screen("loading")
	var cc := CenterContainer.new()
	s.add_child(cc)
	cc.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var v := vbox(cc, 14)
	v.custom_minimum_size = Vector2(460, 0)
	U["load_title"] = mk_label(v, "Menyiapkan…", 28, Color.WHITE, true, HORIZONTAL_ALIGNMENT_CENTER)
	var pb := ProgressBar.new()
	pb.min_value = 0
	pb.max_value = 100
	pb.show_percentage = false
	pb.custom_minimum_size = Vector2(460, 16)
	pb.add_theme_stylebox_override("background", sbox(Color(1, 1, 1, .12), 8))
	pb.add_theme_stylebox_override("fill", sbox(Color("#ff3d81"), 8))
	v.add_child(pb)
	U["load_bar"] = pb
	U["load_sub"] = mk_label(v, "", 15, Color("#b7b1e6"), false, HORIZONTAL_ALIGNMENT_CENTER)

# ================================================================ jeda & hasil
func build_pause() -> void:
	var s := new_screen("pause")
	var cr := ColorRect.new()
	cr.color = Color(.02, .01, .08, .72)
	s.add_child(cr)
	cr.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var cc := CenterContainer.new()
	s.add_child(cc)
	cc.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var v := vbox(cc, 12)
	mk_label(v, "JEDA", 40, Color.WHITE, true, HORIZONTAL_ALIGNMENT_CENTER)
	mk_btn(v, "LANJUT", ui_pause_resume, Color("#ff3d81"), 24, Vector2(300, 56))
	mk_btn(v, "ULANGI", ui_pause_retry, Color("#3aa0ff"), 22, Vector2(300, 50))
	mk_btn(v, "KEMBALI KE PUSTAKA", ui_pause_lib, Color("#2b2354"), 18, Vector2(300, 46))

func on_pause() -> void:
	stats["pauses"] = int(stats["pauses"]) + 1
	save_all()
	go("pause")
	check_ach(null)

func build_result() -> void:
	var s := new_screen("result")
	var cc := CenterContainer.new()
	s.add_child(cc)
	cc.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var h := hbox(cc, 40)
	var l := vbox(h, 0)
	l.custom_minimum_size = Vector2(220, 0)
	U["r_rank"] = mk_label(l, "S", 150, Color.WHITE, true, HORIZONTAL_ALIGNMENT_CENTER)
	U["r_rank"].pivot_offset = Vector2(110, 90)
	var r := vbox(h, 8)
	r.custom_minimum_size = Vector2(430, 0)
	U["r_title"] = mk_label(r, "", 20, Color("#cfc9ff"), true)
	U["r_score"] = mk_label(r, "0", 52, Color.WHITE, true)
	U["r_hp"] = mk_label(r, "", 15, Color("#b7b1e6"))
	U["r_note"] = mk_label(r, "", 16, Color("#ffd24a"), true)
	U["r_grid"] = mk_label(r, "", 18, Color.WHITE)
	var br := hbox(r, 10)
	mk_btn(br, "MAIN LAGI", start_game, Color("#ff3d81"), 20, Vector2(160, 54))
	mk_btn(br, "PUSTAKA", ui_res_lib, Color("#2b2354"), 18, Vector2(130, 54))

func show_result(r: Dictionary, new_rec: bool) -> void:
	gv.stop_game()
	var g := str(r["grade"])
	var cnt: Array = r["cnt"]
	U["r_rank"].text = g
	U["r_rank"].add_theme_color_override("font_color", Color(GRC.get(g.substr(0, 1), "#ffffff")))
	U["r_title"].text = "%s - %s%s" % [r["name"], AN.DF[int(r["diff"])]["n"], " - GAGAL" if r["failed"] else ""]
	U["r_hp"].text = "HP %d%%" % roundi(float(r["hp"]))
	U["r_note"].text = ("Rekor baru! " if new_rec else "") + "Akurasi %.1f%%  -  Kombo maks %d" % [float(r["acc"]) * 100.0, int(r["maxc"])]
	U["r_grid"].text = "Perfect %d    Great %d\nGood %d    Miss %d" % [cnt[2], cnt[1], cnt[0], cnt[3]]
	go("result")
	var rk: Label = U["r_rank"]
	rk.scale = Vector2(3.0, 3.0)
	rk.modulate = Color(1, 1, 1, 0)
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(rk, "scale", Vector2.ONE, .5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(rk, "modulate:a", 1.0, .25)
	var sc: Label = U["r_score"]
	var final_score := int(r["score"])
	var tw2 := create_tween()
	tw2.tween_method(func(v: float): sc.text = fmt_n(int(v)), 0.0, float(final_score), 1.1).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)

# ================================================================ kustomisasi
func build_cust() -> void:
	var s := new_screen("cust")
	top_bar(s, "Kustom", func():
		sfx("click")
		save_all()
		go("menu"))
	var tabs := hbox(s, 8)
	tabs.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	tabs.offset_left = 16.0
	tabs.offset_right = -16.0
	tabs.offset_top = 72.0
	tabs.offset_bottom = 112.0
	var names := ["Warna", "Bentuk", "Kamera", "Efek", "Grafik"]
	var tb: Array = []
	for i in range(5):
		var b := Button.new()
		b.text = names[i]
		b.add_theme_font_size_override("font_size", 16)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.pressed.connect(set_tab.bind(i))
		tabs.add_child(b)
		tb.append(b)
	U["c_tabs"] = tb
	var area := Control.new()
	s.add_child(area)
	area.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	area.offset_left = 16.0
	area.offset_right = -16.0
	area.offset_top = 122.0
	area.offset_bottom = -8.0
	var pn: Array = []
	for i in range(5):
		var p := Control.new()
		area.add_child(p)
		p.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		p.visible = false
		pn.append(p)
	U["c_pan"] = pn
	build_tab_color(pn[0])
	build_tab_shape(pn[1])
	build_tab_camera(pn[2])
	build_tab_fx(pn[3])
	build_tab_gfx(pn[4])

func set_tab(i: int) -> void:
	sfx("click")
	cust_tab = i
	paint_cust()

func fill_cust() -> void:
	colors_flag = false
	paint_cust()
	wheel.rebuild(int(HSL[0]["s"]))
	paint_wheel()

func paint_cust() -> void:
	var tb: Array = U["c_tabs"]
	var pn: Array = U["c_pan"]
	for i in range(5):
		set_sel_style(tb[i], i == cust_tab, Color("#3aa0ff"))
		pn[i].visible = (i == cust_tab)
	paint_opts()

func build_tab_color(p: Control) -> void:
	var h := hbox(p, 24)
	h.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var lanes := vbox(h, 6)
	lanes.custom_minimum_size = Vector2(120, 0)
	mk_label(lanes, "LAJUR", 13, Color("#9e98cc"), true)
	var sw: Array = []
	var keys := ["D", "F", "SPACE", "J", "K"]
	for i in range(5):
		var b := Button.new()
		b.text = keys[i]
		b.add_theme_font_size_override("font_size", 16)
		b.custom_minimum_size = Vector2(110, 46)
		b.pressed.connect(pick_lane.bind(i))
		lanes.add_child(b)
		sw.append(b)
	U["c_sw"] = sw
	wheel = WG.HueWheel.new()
	wheel.custom_minimum_size = Vector2(280, 280)
	wheel.fnt = font
	wheel.picked.connect(on_wheel)
	h.add_child(wheel)
	var r := vbox(h, 10)
	r.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mk_label(r, "KEPEKATAN WARNA", 13, Color("#9e98cc"), true)
	var sr := hbox(r, 8)
	U["c_sat"] = mk_slider(sr, 20.0, 100.0, 1.0, float(HSL[0]["s"]), on_sat)
	U["c_satv"] = mk_label(sr, "", 15, Color("#ffd24a"), true)
	U["c_satv"].custom_minimum_size = Vector2(50, 0)
	(U["c_sat"] as HSlider).drag_ended.connect(func(_c): wheel.rebuild(int(HSL[0]["s"])))
	mk_label(r, "PALET", 13, Color("#9e98cc"), true)
	for k in PALS:
		var b := Button.new()
		b.text = str(k)
		b.add_theme_font_size_override("font_size", 16)
		b.custom_minimum_size = Vector2(0, 40)
		style_btn(b, Color("#2b2354"))
		b.pressed.connect(pick_pal.bind(str(k)))
		r.add_child(b)

func pick_lane(i: int) -> void:
	sfx("click")
	cust_lane = i
	paint_wheel()

func on_wheel(h: float, l: float) -> void:
	HSL[cust_lane]["h"] = h
	HSL[cust_lane]["l"] = roundf(l)
	apply_colors()
	if not colors_flag:
		colors_flag = true
		stats["colors"] = int(stats["colors"]) + 1
		check_ach(null)
	paint_wheel()

func on_sat(v: float) -> void:
	for o in HSL:
		o["s"] = v
	apply_colors()
	U["c_satv"].text = "%d%%" % int(v)
	paint_wheel(false)

func pick_pal(k: String) -> void:
	sfx("click")
	var pal: Array = PALS[k]
	HSL = []
	for h in pal:
		HSL.append(hex_to_hsl(Color(h)))
	apply_colors()
	stats["colors"] = int(stats["colors"]) + 1
	save_all()
	check_ach(null)
	wheel.rebuild(int(HSL[0]["s"]))
	paint_wheel()

func paint_wheel(set_slider: bool = true) -> void:
	var sw: Array = U["c_sw"]
	for i in range(5):
		var b: Button = sw[i]
		var c: Color = COL[i]
		style_btn(b, c, Color.BLACK if c.get_luminance() > .5 else Color.WHITE)
		if i == cust_lane:
			b.add_theme_stylebox_override("normal", sbox(c, 18, Color.WHITE, 4))
	wheel.set_color(float(HSL[cust_lane]["h"]), float(HSL[cust_lane]["l"]))
	if set_slider:
		U["c_sat"].set_value_no_signal(float(HSL[0]["s"]))
	U["c_satv"].text = "%d%%" % int(HSL[0]["s"])

# ---- opsi bergambar sederhana: baris tombol pilihan
func opt_row(par: Node, title: String, names: Array, key: String) -> void:
	mk_label(par, title, 13, Color("#9e98cc"), true)
	var h := hbox(par, 8)
	var bs: Array = []
	for i in range(names.size()):
		var b := Button.new()
		b.text = names[i]
		b.add_theme_font_size_override("font_size", 16)
		b.custom_minimum_size = Vector2(0, 46)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.pressed.connect(set_opt.bind(key, i))
		h.add_child(b)
		bs.append(b)
	U["o_" + key] = bs

func set_opt(key: String, i: int) -> void:
	sfx("click")
	SET[key] = (i + 1) if key == "gen" else i
	save_all()
	gv.relayout()
	paint_opts()

func tog_row(par: Node, title: String, desc: String, key: String) -> void:
	var h := hbox(par, 12)
	var v := vbox(h, 0)
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mk_label(v, title, 18, Color.WHITE, true)
	mk_label(v, desc, 13, Color("#b7b1e6"))
	var b := Button.new()
	b.custom_minimum_size = Vector2(110, 46)
	b.add_theme_font_size_override("font_size", 16)
	b.pressed.connect(func():
		sfx("click")
		SET[key] = not bool(SET[key])
		save_all()
		paint_opts())
	h.add_child(b)
	U["t_" + key] = b

func paint_opts() -> void:
	for key in ["hole", "nshape", "gen"]:
		if U.has("o_" + key):
			var bs: Array = U["o_" + key]
			var cur_v := int(SET[key])
			for i in range(bs.size()):
				var idx := i + 1 if key == "gen" else i
				set_sel_style(bs[i], idx == cur_v)
	for key in ["parts", "glow", "vib"]:
		if U.has("t_" + key):
			var b: Button = U["t_" + key]
			var on := bool(SET[key])
			b.text = "AKTIF" if on else "MATI"
			style_btn(b, Color("#2ee6a6") if on else Color("#3a3560"), Color("#06241a") if on else Color.WHITE)
	if U.has("g_v2box"):
		U["g_v2box"].visible = int(SET["gen"]) == 2
		U["g_v2th"].set_value_no_signal(float(SET["v2th"]))
		U["g_v2thv"].text = "%d%%" % int(SET["v2th"])
		U["g_v2cd"].set_value_no_signal(float(SET["v2cd"]))
		U["g_v2cdv"].text = "%d ms" % int(SET["v2cd"])
	if U.has("k_tilt"):
		U["k_tilt"].set_value_no_signal(float(SET["tilt"]))
		U["k_tiltv"].text = ("%d%%" % int(SET["tilt"])) if int(SET["tilt"]) > 0 else "Mati"

func build_tab_shape(p: Control) -> void:
	var v := vbox(p, 10)
	v.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	opt_row(v, "BENTUK LUBANG TOMBOL", ["Pil", "Bulat", "Persegi panjang", "Persegi"], "hole")
	opt_row(v, "BENTUK NOT", ["Pil", "Persegi", "Balok"], "nshape")

func build_tab_camera(p: Control) -> void:
	var v := vbox(p, 12)
	v.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mk_label(v, "KEMIRINGAN KAMERA", 13, Color("#9e98cc"), true)
	var h := hbox(v, 10)
	U["k_tilt"] = mk_slider(h, 0.0, 100.0, 1.0, float(SET["tilt"]), func(val: float):
		SET["tilt"] = int(val)
		gv.relayout()
		paint_opts()
		save_all())
	U["k_tiltv"] = mk_label(h, "", 16, Color("#ffd24a"), true)
	U["k_tiltv"].custom_minimum_size = Vector2(70, 0)
	mk_label(v, "Makin tinggi, jalur makin miring ke belakang (efek 3D). Mati = tampilan datar.", 14, Color("#b7b1e6"))

func build_tab_fx(p: Control) -> void:
	var v := vbox(p, 12)
	v.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tog_row(v, "Partikel", "Percikan dan cairan saat not kena", "parts")
	tog_row(v, "Cahaya", "Cahaya latar berdenyut mengikuti bass", "glow")
	tog_row(v, "Getar", "Getaran singkat saat not kena", "vib")

func build_tab_gfx(p: Control) -> void:
	var v := vbox(p, 10)
	v.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	opt_row(v, "GENERATOR NOT", ["V1 - 5 pita frekuensi", "V2 - pemindai bass"], "gen")
	var box := vbox(v, 8)
	U["g_v2box"] = box
	var h1 := hbox(box, 8)
	mk_label(h1, "Sensitivitas", 15, Color.WHITE, true).custom_minimum_size = Vector2(120, 0)
	U["g_v2th"] = mk_slider(h1, 0.0, 100.0, 1.0, float(SET["v2th"]), func(val: float):
		SET["v2th"] = int(val)
		save_all()
		paint_opts())
	U["g_v2thv"] = mk_label(h1, "", 15, Color("#ffd24a"), true)
	U["g_v2thv"].custom_minimum_size = Vector2(70, 0)
	var h2 := hbox(box, 8)
	mk_label(h2, "Jeda antar not", 15, Color.WHITE, true).custom_minimum_size = Vector2(120, 0)
	U["g_v2cd"] = mk_slider(h2, 100.0, 600.0, 10.0, float(SET["v2cd"]), func(val: float):
		SET["v2cd"] = int(val)
		save_all()
		paint_opts())
	U["g_v2cdv"] = mk_label(h2, "", 15, Color("#ffd24a"), true)
	U["g_v2cdv"].custom_minimum_size = Vector2(70, 0)
	mk_label(v, "Perubahan generator berlaku saat menekan MULAI pada lagu berikutnya.", 13, Color("#b7b1e6"))
	mk_label(v, "Batas FPS: 90 - gambar langsung di GPU, resolusi layar penuh.", 13, Color("#b7b1e6"))

# ---------------------------------------------------------------- aksi tombol (fungsi bernama)
func ui_upload() -> void:
	sfx("click")
	open_browser()

func ui_browser_done() -> void:
	sfx("click")
	go("lib")

func ui_browser_up() -> void:
	var p := br_path.get_base_dir()
	if p != "" and p != br_path:
		br_path = p
		browser_refresh()

func ui_quick(label: String, sub: String) -> void:
	var p: String = root_dir().path_join(sub)
	if DirAccess.dir_exists_absolute(p):
		br_path = p
		browser_refresh()
	else:
		toast("Folder " + label + " tidak ditemukan.")

func ui_perm() -> void:
	ask_perms()
	toast("Izinkan akses musik/penyimpanan, lalu kembali ke game.")

func ui_enter(dn: String) -> void:
	br_path = br_path.path_join(dn)
	browser_refresh()

func ui_pause_resume() -> void:
	sfx("click")
	go("game")
	gv.resume_game()

func ui_pause_retry() -> void:
	gv.stop_game()
	start_game()

func ui_pause_lib() -> void:
	sfx("click")
	gv.stop_game()
	go("lib")

func ui_res_lib() -> void:
	sfx("click")
	refresh_lib(str(sel.get("id", "")))
	go("lib")

func ui_del_cancel() -> void:
	sfx("click")
	U["del_box"].visible = false

func ui_del_ok() -> void:
	sfx("click")
	U["del_box"].visible = false
	remove_song(str(U["del_id"]))
	toast("Lagu dihapus dari daftar.")
