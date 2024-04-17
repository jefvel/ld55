extends Label

func _physics_process(delta):
	queue_redraw()
	pass

func _draw():
	
	var font = get("theme_override_fonts/font")
	draw_string(font, Vector2.ZERO, "HELLO", HORIZONTAL_ALIGNMENT_CENTER, -1, 32);
	pass
