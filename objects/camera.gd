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
			_t.tween_property(self, "_dz_y", dz, 0.75);
		deadzone_y = dz;
		
func shake():
	rotation = randf_range(0.05, 0.12) * (-1 if randf() < 0.5 else 1)
	var tr = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tr.tween_property(self, "rotation", 0.0, 0.1)
	pass

func _process(_delta):
	if follow_target:
		position.x = follow_target.position.x
		var dy = position.y - follow_target.position.y
		position.x += _offset.x;
		#position.x = clamp(position.x, -999, 1000)
		#print(position.x)
		if abs(dy) > _dz_y:
			var d = (abs(dy) - _dz_y) * sign(dy);
			position.y -= d;

var _offset: Vector2
var off_tween: Tween;
func tween_offset(off_x: float, off_y: float) -> void:
	if off_tween:
		off_tween.kill();
		off_tween = null
	off_tween = get_tree().create_tween()
	off_tween.set_ease(Tween.EASE_OUT)
	off_tween.set_trans(Tween.TRANS_CUBIC)
	off_tween.tween_property(self, "offset", Vector2(off_x, off_y), 0.47)
	off_tween.play()
