extends Label

var time = 0.0 + randf() * 10.0;
var spd = randf_range(0.98, 1.02)
var spd_inc = 0.0;
var prevText = "";
var letter_scales : Array[Vector2] = [];
var start_scl: Vector2;
func _physics_process(delta):
	queue_redraw()
	time += delta * (spd + spd_inc);
	if text != prevText:
		start_scl.x += 40.0;
		spd_inc += randf_range(20.0, 32.0)
		prevText = text;
	spd_inc *= 0.9
	start_scl *= 0.5;
	var scl = start_scl;
	for s in range(letter_scales.size()):
		var ls = letter_scales[s];
		var ds = (scl.x - (ls.x)) * 0.4
		
		ls.y += ds;
		ls.x += ls.y;
		ls.y *= 0.35;
		
		letter_scales[s] = ls;
		scl.x = ls.x * 0.98;
		
	pass

func _ready() -> void:
	set("theme_override_colors/font_color", Color.TRANSPARENT)
	if letter_scales.size() < text.length():
		letter_scales.resize(text.length() + 1)
	pass

func _draw():
	var font: Font = get("theme_override_fonts/font")
	var ascent = font.get_ascent(32);
	var i = 0;
	
	for char in text:
		if i >= letter_scales.size(): letter_scales.push_back(Vector2.ZERO)
		var p = letter_scales[i].x * 0.05
		var scl = p + 1;
		var rect = get_character_bounds(i)
		var s = rect.size;
		s.y = -ascent
		s *= scl
		#s.x = -s.x;
		#if rect.size.is_zero_approx():
		#	continue
		var pos = rect.position# + Vector2(10, 10)
		pos.y += ascent;
		
		#draw_string(font, pos, "0", HORIZONTAL_ALIGNMENT_LEFT, -1, 32);
		# draw_rect(rect, Color.CYAN, false)
		var a = sin(i * 0.6 + time * 3.0) * 0.2 - p
		#pos.y += 
		#print(pos)
		var tform = Transform2D()
		#tform = tform.rotated(a)
		tform = tform.translated_local(pos + Vector2.ONE + s * 0.5 / Vector2(scl, scl) - Vector2(0, p * 16))
		tform = tform.rotated_local(a)
		tform = tform.translated_local(-s * 0.5).scaled_local(Vector2(scl, scl))
		draw_set_transform_matrix(tform)
		#draw_set_transform(pos + size * 0.5);
		#draw_set_transform(Vector2.ZERO, 0.1 + sin(i + time), Vector2.ONE)
		draw_string(font, Vector2.ZERO, char, HORIZONTAL_ALIGNMENT_FILL, -1, 32, modulate, justification_flags)
		i += 1
	pass
