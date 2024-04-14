extends RigidBody2D
class_name Enemy

@export var sprite: Sprite2D

var dead = false;
var velocity: Vector2;
var rv: float;


func _ready():
	#sleeping = false;
	pass

func fade_out():
	if dead: return
	dead = true
	dead_time = randf_range(0.0, 0.3)
	pass

func hurt(e):
	if dead: return
	dead = true
	
	velocity = e.velocity
	rv = randf_range(-0.1, 0.1)
	pass

var dead_time = 0.0
func _physics_process(delta):
	if !dead:
		return
	position += velocity;
	rotation += rv
	rv *= 0.9
	velocity *= 0.92
	dead_time += delta
	if dead_time > 0.4:
		modulate.a = lerp(modulate.a, 0.0, 0.4)
		if modulate.a < 0.01:
			queue_free()
