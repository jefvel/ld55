extends Camera2D
class_name GameCamera

@export var follow_target: Node2D;

func _process(_delta):
	if follow_target:
		position = follow_target.position

var off_tween: Tween;
func tween_offset(off_x: float, off_y: float) -> void:
	if off_tween:
		off_tween.kill();
		off_tween = null
	off_tween = get_tree().create_tween()
	off_tween.set_ease(Tween.EASE_OUT)
	off_tween.set_trans(Tween.TRANS_CUBIC)
	off_tween.tween_property(self, "offset", Vector2(off_x, off_y), 0.35)
	off_tween.play()
