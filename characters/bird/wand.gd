extends Sprite2D
var velocity : Vector2
var rvel = 0.0;
var dropped = false;
func drop():
	dropped = true;
	rvel = randf_range(-0.5, 0.5)
	velocity.y = randf_range(-4, -10)
	velocity.x = randf_range(-2, 2)
	pass

func _physics_process(delta):
	if !dropped:
		return
		
	rotation += rvel;
	position += velocity;
	rvel *= 0.99;
	velocity.y += 0.3;
	velocity *= 0.96;
	
