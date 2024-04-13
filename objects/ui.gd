extends Control
@onready var color_rect = $ColorRect
func _ready():
	color_rect.visible = true;
	var t = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	t.tween_property(color_rect, "modulate:a", 0, 0.1)
	t.finished.connect(_finish)

func _finish():
	color_rect.visible = false;
	pass
