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
	if captured: captured = false
	if dead: return
	dead = true
	velocity = e.velocity
	rv = randf_range(-0.1, 0.1)
	pass
	
var captured = false
func capture(e: Item):
	if captured: return
	captured = true
	dead = true
	velocity = e.velocity
	rv = randf_range(-0.1, 0.1)
	Game.bird.enemy_collected(self)
	pass

var collect_queue_index = 0;

var dead_time = 0.0
var tar_pos: Vector2;

var turning = false;
var until_turn = 0.0
func turn_into_slug(delay:float = 0.0):
	if turning: return
	turning = true
	until_turn = delay
	pass
	
const ROPE_BLOB = preload("res://objects/rope_blob.tscn")
func activate_turn():
	var par = get_parent()
	var blob = ROPE_BLOB.instantiate()
	blob.position = position
	par.add_child(blob)
	queue_free()
	pass

func _physics_process(delta):
	if !dead:
		return
	if captured and Game.bird:
			
		var tar_len = 50.0 if collect_queue_index > 0 else 50.0;
		
		if turning and collect_queue_index == 0:
			tar_len = 99999999.9;
		var d = Game.bird.get_queue_position(collect_queue_index - 1) - tar_pos
		if d.length_squared() > tar_len * tar_len:
			var dl = d.length();
			d = d.normalized();
			dl = dl - tar_len
			d *= dl
			tar_pos += d
		velocity += ((tar_pos - position) * 0.04).limit_length(2.0);
	
	if turning:
		velocity *= 0.3
		until_turn -= delta;
		if until_turn <= 0.0:
			activate_turn();
	
	position += velocity;
	rotation += rv
	rv *= 0.9
	velocity *= 0.92
	
	if !captured:
		dead_time += delta
	if dead_time > 0.4:
		modulate.a = lerp(modulate.a, 0.0, 0.4)
		if modulate.a < 0.01:
			queue_free()
