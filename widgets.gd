extends RefCounted
# widgets.gd - komponen tampilan buatan sendiri (digambar lewat kode, tanpa gambar tambahan)

# ------------------------------------------------------------------ latar bergerak
class BgFx extends Control:
	var t := 0.0
	var pulse := 0.0
	var seeds: Array = []

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		for i in range(14):
			seeds.append([randf(), randf(), .15 + randf() * .5, randf() * TAU, 10.0 + randf() * 26.0])

	func _process(delta: float) -> void:
		t += delta
		if is_visible_in_tree():
			queue_redraw()

	func _blob(c: Vector2, r: float, col: Color) -> void:
		for i in range(10):
			var k := float(i) / 10.0
			draw_circle(c, r * (1.0 - k * .9), Color(col.r, col.g, col.b, col.a * .1))

	func _draw() -> void:
		var c0 := Color("#0d0a26")
		var c1 := Color("#1c0b30")
		draw_polygon(PackedVector2Array([Vector2(0, 0), Vector2(size.x, 0), size, Vector2(0, size.y)]), PackedColorArray([c0, c0, c1, c1]))
		_blob(Vector2(size.x * .2 + sin(t * .3) * 40.0, size.y * .25), size.y * .7, Color(1.0, .24, .5, .5))
		_blob(Vector2(size.x * .85 + cos(t * .25) * 40.0, size.y * .8), size.y * .8, Color(.3, .4, 1.0, .5))
		_blob(Vector2(size.x * .5, size.y * .5 + sin(t * .2) * 30.0), size.y * .6, Color(.55, .3, 1.0, .35))
		for s in seeds:
			var y: float = fposmod(1.0 - (t * float(s[2]) * .04 + float(s[1])), 1.0) * (size.y + 60.0) - 30.0
			var x: float = float(s[0]) * size.x + sin(t * .5 + float(s[3])) * 22.0
			var r: float = float(s[4])
			var a := t * .4 + float(s[3])
			var pts := PackedVector2Array()
			for k in range(4):
				var an := a + k * PI * .5
				pts.append(Vector2(x + cos(an) * r, y + sin(an) * r))
			pts.append(pts[0])
			draw_polyline(pts, Color(1, 1, 1, .09), 1.5)

# ------------------------------------------------------------------ kartu menu besar
class MenuCard extends Control:
	signal pressed
	var kind := 0
	var label := ""
	var sub := ""
	var accent := Color("#ff3d81")
	var down := false
	var fnt: Font
	var sb := StyleBoxFlat.new()
	var t := 0.0

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_STOP
		sb.bg_color = Color(.07, .05, .16, .86)
		sb.set_corner_radius_all(26)
		sb.set_border_width_all(3)
		sb.shadow_size = 14
		sb.shadow_color = Color(0, 0, 0, .5)
		resized.connect(func(): pivot_offset = size / 2.0)

	func _process(delta: float) -> void:
		t += delta
		if is_visible_in_tree():
			queue_redraw()

	func _gui_input(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT:
			if ev.pressed:
				down = true
				scale = Vector2(.96, .96)
			else:
				if down and Rect2(Vector2.ZERO, size).has_point(ev.position):
					pressed.emit()
				down = false
				scale = Vector2.ONE

	func _draw() -> void:
		sb.border_color = accent
		draw_style_box(sb, Rect2(Vector2.ZERO, size))
		var c := Vector2(size.x / 2.0, size.y * .42)
		var r := minf(size.x, size.y) * .22
		var pul := 1.0 + sin(t * 2.5) * .05
		for i in range(8):
			draw_circle(c, r * 1.5 * pul * (1.0 - i * .1), Color(accent.r, accent.g, accent.b, .035))
		if kind == 0:
			draw_colored_polygon(PackedVector2Array([c + Vector2(-r * .55, -r * .8), c + Vector2(r * .9, 0), c + Vector2(-r * .55, r * .8)]), accent)
		elif kind == 1:
			draw_colored_polygon(PackedVector2Array([c + Vector2(-r * .7, -r * .8), c + Vector2(r * .7, -r * .8), c + Vector2(r * .45, r * .15), c + Vector2(-r * .45, r * .15)]), accent)
			draw_arc(c + Vector2(-r * .8, -r * .45), r * .35, PI * .5, PI * 1.5, 12, accent, 5.0)
			draw_arc(c + Vector2(r * .8, -r * .45), r * .35, -PI * .5, PI * .5, 12, accent, 5.0)
			draw_rect(Rect2(c.x - r * .1, c.y + r * .15, r * .2, r * .45), accent)
			draw_rect(Rect2(c.x - r * .5, c.y + r * .6, r * 1.0, r * .2), accent)
		else:
			for k in range(8):
				var a := t * .5 + k * TAU / 8.0
				draw_line(c + Vector2(cos(a), sin(a)) * r * .75, c + Vector2(cos(a), sin(a)) * r * 1.05, accent, 7.0)
			draw_arc(c, r * .75, 0.0, TAU, 28, accent, 7.0)
			draw_circle(c, r * .28, accent)
		if fnt != null:
			draw_string(fnt, Vector2(0, size.y * .82), label, HORIZONTAL_ALIGNMENT_CENTER, size.x, 26, Color.WHITE)
			draw_string(fnt, Vector2(0, size.y * .82 + 22.0), sub, HORIZONTAL_ALIGNMENT_CENTER, size.x, 13, Color(.72, .7, .9))

# ------------------------------------------------------------------ carousel lagu (cover-flow)
class Carousel extends Control:
	signal opened(id)
	signal long_pressed(id)
	signal centered(idx)
	var items: Array = []
	var pos := 0.0
	var target := 0.0
	var dragging := false
	var d_x0 := 0.0
	var d_pos0 := 0.0
	var d_t0 := 0.0
	var d_moved := false
	var d_idx := -1
	var vel := 0.0
	var last_x := 0.0
	var last_t := 0.0
	var lp_fired := false
	var empty_text := ""
	var fnt: Font
	var fnt_b: Font
	var last_center := -1

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_STOP
		clip_contents = true

	func set_items(arr: Array, keep_id: String = "") -> void:
		items = arr
		var idx := 0
		if keep_id != "":
			for i in range(items.size()):
				if items[i].id == keep_id:
					idx = i
		pos = float(idx)
		target = float(idx)
		last_center = -1

	func center_index() -> int:
		return clampi(roundi(target), 0, maxi(0, items.size() - 1))

	func card_h() -> float:
		return clampf(size.y - 20.0, 120.0, 460.0)

	func card_w() -> float:
		return card_h() * .76

	func spacing() -> float:
		return card_w() * .62

	func _now() -> float:
		return Time.get_ticks_msec() / 1000.0

	func card_at(p: Vector2) -> int:
		var best := -1
		var bd := 99.0
		for i in range(items.size()):
			var o := float(i) - pos
			var sc := 1.0 - minf(absf(o), 2.0) * .06
			var cx := size.x / 2.0 + o * spacing()
			var hw := card_w() * sc / 2.0
			var hh := card_h() * sc / 2.0
			if absf(p.x - cx) <= hw and absf(p.y - size.y / 2.0) <= hh and absf(o) < bd:
				bd = absf(o)
				best = i
		return best

	func _process(delta: float) -> void:
		if not is_visible_in_tree():
			return
		if not dragging:
			pos = lerpf(pos, target, 1.0 - exp(-delta * 11.0))
			if absf(pos - target) < .002:
				pos = target
		elif not d_moved and not lp_fired and d_idx >= 0 and d_idx == center_index() and _now() - d_t0 > .75:
			lp_fired = true
			long_pressed.emit(items[d_idx].id)
		var ci := center_index()
		if ci != last_center:
			last_center = ci
			centered.emit(ci)
		queue_redraw()

	func _gui_input(ev: InputEvent) -> void:
		if items.is_empty():
			return
		if ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT:
			if ev.pressed:
				dragging = true
				d_x0 = ev.position.x
				d_pos0 = pos
				d_moved = false
				d_t0 = _now()
				vel = 0.0
				last_x = ev.position.x
				last_t = _now()
				lp_fired = false
				d_idx = card_at(ev.position)
			elif dragging:
				dragging = false
				if lp_fired:
					return
				if not d_moved:
					var idx := card_at(ev.position)
					if idx == center_index():
						opened.emit(items[idx].id)
					elif idx >= 0:
						target = float(idx)
				else:
					target = clampf(roundf(pos - vel * .12), 0.0, float(items.size() - 1))
		elif ev is InputEventMouseMotion and dragging:
			var dx: float = ev.position.x - d_x0
			if absf(dx) > 12.0:
				d_moved = true
			if d_moved:
				pos = clampf(d_pos0 - dx / spacing(), -.3, float(items.size()) - .7)
				var dt := _now() - last_t
				if dt > 0.0:
					vel = lerpf(vel, (ev.position.x - last_x) / dt / spacing(), .5)
				last_x = ev.position.x
				last_t = _now()

	func _draw() -> void:
		if items.is_empty():
			if fnt != null:
				draw_multiline_string(fnt, Vector2(0, size.y / 2.0 - 10.0), empty_text, HORIZONTAL_ALIGNMENT_CENTER, size.x, 18, -1, Color(.72, .7, .9))
			return
		var order: Array = []
		for i in range(items.size()):
			if absf(float(i) - pos) < 3.3:
				order.append(i)
		order.sort_custom(func(a, b): return absf(float(a) - pos) > absf(float(b) - pos))
		for i in order:
			_draw_card(i)

	func _draw_card(i: int) -> void:
		var it: Dictionary = items[i]
		var o := float(i) - pos
		var ao := absf(o)
		var sc := 1.0 - minf(ao, 2.0) * .06
		var cx := size.x / 2.0 + o * spacing()
		var cy := size.y / 2.0
		var w := card_w() * sc
		var h := card_h() * sc
		var edge := 1.0 - minf(ao, 1.0) * .12
		var hl := h
		var hr := h
		if o > 0.0:
			hr = h * edge
		elif o < 0.0:
			hl = h * edge
		var al := maxf(.35, 1.0 - ao * .22)
		var tl := Vector2(cx - w / 2.0, cy - hl / 2.0)
		var trp := Vector2(cx + w / 2.0, cy - hr / 2.0)
		var br := Vector2(cx + w / 2.0, cy + hr / 2.0)
		var bl := Vector2(cx - w / 2.0, cy + hl / 2.0)
		var quad := PackedVector2Array([tl, trp, br, bl])
		var tex: Texture2D = it.tex
		if tex != null:
			var asp := .76
			var u0 := .5 - asp / 2.0
			var u1 := .5 + asp / 2.0
			var cols := PackedColorArray([Color(1, 1, 1, al), Color(1, 1, 1, al), Color(1, 1, 1, al), Color(1, 1, 1, al)])
			draw_polygon(quad, cols, PackedVector2Array([Vector2(u0, 0), Vector2(u1, 0), Vector2(u1, 1), Vector2(u0, 1)]), tex)
		else:
			var c0 := Color(.35, .2, .8, al)
			var c1 := Color(.9, .2, .55, al)
			draw_polygon(quad, PackedColorArray([c0, c0, c1, c1]))
			var ic := Vector2(cx, cy - h * .08)
			draw_circle(ic + Vector2(-h * .06, h * .1), h * .07, Color(1, 1, 1, .85 * al))
			draw_line(ic + Vector2(h * .0, h * .1), ic + Vector2(h * .0, -h * .16), Color(1, 1, 1, .85 * al), maxf(3.0, h * .02))
			draw_line(ic + Vector2(h * .0, -h * .16), ic + Vector2(h * .1, -h * .09), Color(1, 1, 1, .85 * al), maxf(3.0, h * .02))
		# bayangan bawah untuk teks
		var dark := Color(.02, .01, .08, .92 * al)
		var clear := Color(.02, .01, .08, 0.0)
		var m0 := tl.lerp(bl, .62)
		var m1 := trp.lerp(br, .62)
		draw_polygon(PackedVector2Array([m0, m1, br, bl]), PackedColorArray([clear, clear, dark, dark]))
		if fnt_b != null:
			var tx := cx - w / 2.0 + 12.0
			var tw := w - 24.0
			draw_multiline_string(fnt_b, Vector2(tx, bl.y - 46.0 * sc - 14.0), str(it.name), HORIZONTAL_ALIGNMENT_LEFT, tw, int(18.0 * sc), 2, Color(1, 1, 1, al))
			draw_string(fnt, Vector2(tx, bl.y - 14.0), str(it.meta), HORIZONTAL_ALIGNMENT_LEFT, tw, int(12.0 * sc), Color(.72, .7, .9, al))
		var g := str(it.grade)
		if g != "":
			var gb := Rect2(tl.x + 8.0, tl.y + 8.0, 38.0 * sc, 28.0 * sc)
			draw_rect(gb, Color(0, 0, 0, .55 * al))
			if fnt_b != null:
				draw_string(fnt_b, Vector2(gb.position.x, gb.position.y + 21.0 * sc), g, HORIZONTAL_ALIGNMENT_CENTER, gb.size.x, int(18.0 * sc), it.gcol)
		if ao < .5:
			var pts := PackedVector2Array([tl, trp, br, bl, tl])
			draw_polyline(pts, Color(1.0, .24, .5, 1.0 - ao * 2.0), 3.0)
			if fnt != null and fnt_b != null:
				var pul := .55 + .45 * sin(Time.get_ticks_msec() / 260.0)
				draw_string(fnt_b, Vector2(cx - w / 2.0, tl.y - 6.0), "KETUK UNTUK MAIN", HORIZONTAL_ALIGNMENT_CENTER, w, 12, Color(1, 1, 1, pul * (1.0 - ao * 2.0)))

# ------------------------------------------------------------------ roda warna (hue = sudut, terang = jari-jari)
class HueWheel extends Control:
	signal picked(h, l)
	var tex: ImageTexture
	var sat := 100
	var hue := 0.0
	var lig := 60.0
	var ring_o := .47
	var ring_i := .30
	var fnt: Font
	var knob_col := Color.WHITE
	var _drag := false
	const LMIN := 30.0
	const LMAX := 90.0

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_STOP

	static func hsl2rgb(h: float, s: float, l: float) -> Color:
		var a := s * minf(l, 1.0 - l)
		var f := func(n: float) -> float:
			var k := fposmod(n + h / 30.0, 12.0)
			return l - a * maxf(-1.0, minf(minf(k - 3.0, 9.0 - k), 1.0))
		return Color(f.call(0.0), f.call(8.0), f.call(4.0))

	func rebuild(s: int) -> void:
		sat = s
		var n := 180
		var img := Image.create(n, n, false, Image.FORMAT_RGBA8)
		img.fill(Color(0, 0, 0, 0))
		var c := n / 2.0
		for y in range(n):
			for x in range(n):
				var dx := x + .5 - c
				var dy := y + .5 - c
				var d := sqrt(dx * dx + dy * dy) / n
				if d < ring_i - .005 or d > ring_o + .005:
					continue
				var h := fposmod(rad_to_deg(atan2(dy, dx)) + 90.0, 360.0)
				var l := LMAX - (d - ring_i) / (ring_o - ring_i) * (LMAX - LMIN)
				var col := hsl2rgb(h, float(s) / 100.0, clampf(l, LMIN, LMAX) / 100.0)
				img.set_pixel(x, y, col)
		tex = ImageTexture.create_from_image(img)
		queue_redraw()

	func set_color(h: float, l: float) -> void:
		hue = h
		lig = l
		queue_redraw()

	func _pick(p: Vector2) -> void:
		var c := size / 2.0
		var d := (p - c)
		var m := minf(size.x, size.y)
		var r := clampf(d.length() / m, ring_i, ring_o)
		hue = fposmod(rad_to_deg(atan2(d.y, d.x)) + 90.0, 360.0)
		lig = LMAX - (r - ring_i) / (ring_o - ring_i) * (LMAX - LMIN)
		picked.emit(hue, lig)
		queue_redraw()

	func _gui_input(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT:
			if ev.pressed:
				var c := size / 2.0
				var m := minf(size.x, size.y)
				var r: float = (ev.position - c).length() / m
				if r >= ring_i - .05 and r <= ring_o + .05:
					_drag = true
					_pick(ev.position)
			else:
				_drag = false
		elif ev is InputEventMouseMotion and _drag:
			_pick(ev.position)

	func _draw() -> void:
		var m := minf(size.x, size.y)
		var c := size / 2.0
		if tex != null:
			draw_texture_rect(tex, Rect2(c - Vector2(m, m) / 2.0, Vector2(m, m)), false)
		var r := ring_i + (LMAX - lig) / (LMAX - LMIN) * (ring_o - ring_i)
		var a := deg_to_rad(hue - 90.0)
		var kp := c + Vector2(cos(a), sin(a)) * r * m
		draw_circle(kp, 11.0, Color.WHITE)
		draw_circle(kp, 8.0, hsl2rgb(hue, float(sat) / 100.0, lig / 100.0))
		draw_circle(c, m * .13, hsl2rgb(hue, float(sat) / 100.0, lig / 100.0))
		draw_arc(c, m * .13, 0.0, TAU, 28, Color(1, 1, 1, .8), 2.0)
