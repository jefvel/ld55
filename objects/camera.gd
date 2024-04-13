extends Camera2D
class_name GameCamera

@export var follow_target: Node2D;

var _dz_y: float = 80.0;
var _t: Tween
var deadzone_y = 80.0:
	set(dz):
		if abs(dz - deadzone_y) > 0.01:
			if _t: _t.kill()
			_t = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
			_t.tween_property(self, "_dz_y", dz, 0.5);
			pass
		deadzone_y = dz;

func _process(_delta):
	if follow_target:
		position.x = follow_target.position.x
		var dy = position.y - follow_target.position.y
		if abs(dy) > _dz_y:
			var d = (abs(dy) - _dz_y) * sign(dy);
			position.y -= d;

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
