extends Node2D
class_name Bird;

@onready var anim = $anim
@onready var sprite = $Sprite

@export var cam: GameCamera;

@export var gravity: float = 0.4;
var velocity: Vector2

signal on_start_flying;
signal on_hit_wall;
signal on_start_gliding;
signal on_landed;
signal on_died;

@export var rope_attach_point: Node2D;
@export var rope_container_node: Node2D;

var thread_total = 20.0;
var cur_thread = thread_total;

var hurting = false;

var rope_segments: Array[Rope]
var glide_rope_index: int = 0;
var current_rope: Rope;

var max_height_per_row = 300.0;

@export var left_x = -666;
@export var right_x = 999 + 333;

var floor_y = 600;

enum State {
	Idle,
	Sitting,
	Flying,
	Falling,
	Gliding,
	Finished,
	Crashed,
}

var state: State = State.Idle;

var flapping = false;
var flapped = false;

var boost = 0.0;

# <-1     1 >
var direction: int = 1 if randf() > 0.5 else -1;

var spawn_pos: Vector2;
func _ready():
	var spawns = get_tree().get_nodes_in_group("PlayerSpawn").pick_random()
	spawn_pos = spawns.global_position
	global_position = spawns.global_position
	anim.play("idle")
	_refresh();
	_create_rope();
	
@onready var rope_end = $rope_end

func _create_rope():
	if current_rope:
		rope_segments.push_back(current_rope)
	var rope = Rope.new()
	rope_container_node.add_child(rope)
	rope.end_node = rope_end;
	rope.start_node = rope_attach_point
	#rope_segments.push_back(rope)
	current_rope = rope;
	pass

func start_flying():
	state = State.Flying;
	on_start_flying.emit()
	update_cam()
	cam.deadzone_y = 85.0;
	pass

func crash():
	rotation = 0;
	state = State.Crashed
	position.y = floor_y
	anim.play("dead")
	on_died.emit();
	#Game.hit_freeze(0.1)
	cam.shake()
	
func update_cam():
	var off_x = 120.0;
	const off_y = -16.0;
	if direction < 0:
		off_x = -off_x;
	cam.tween_offset(off_x, off_y)

func land_on_wall():
	if state == State.Sitting:
		return
	
	cam.deadzone_y = 0.0;
	state = State.Sitting
	
	velocity.x = 0;
	velocity.y = 0;
	
	flapping = false;
	flapped = false;
	
	anim.play("wallsit")
	
	rotation = 0;
	
	if direction > 0:
		position.x = right_x + 1;
	else:
		position.x = left_x - 1
	
	direction = -direction;
	update_cam();


	var n = ROSETTE.instantiate()
	if direction < 0:
		n.scale.x = -1;
	rope_container_node.add_child(n)
	n.global_position = rope_end.global_position
	current_rope.end_node = n
	rope_attach_point = n
	_create_rope()
	
	on_hit_wall.emit();
	
func hurt():
	hurting = true;
	cur_thread -= 10.0;
	anim.play("ouch")
	Game.hit_freeze()
	cam.shake()

const ROSETTE = preload("res://objects/rosette.tscn")
func _refresh():
	if direction < 0:
		sprite.scale.x = -1;
	elif direction > 0:
		sprite.scale.x = 1;

var flap_request = false;
var flap_released = false;
func _physics_process(_delta):
	var flap_pressed = Input.is_action_just_pressed("FLAP")
	var flap_down = Input.is_action_pressed("FLAP")
	
	if !flap_down:
		flap_released = true;
	
	if Game.frozen:
		return
	
	_refresh()
	if flap_pressed:
		if state == State.Idle or state == State.Sitting:
			start_flying();
		pass
	
	var gravity_scale = 1.0;
	if !flap_down:
		boost *= 0.5;
		gravity_scale = 1.2;
	else:
		gravity_scale = 0.6;
		boost *= 0.99
		
	if state == State.Flying:
		velocity.y += gravity * gravity_scale;
		velocity.x = (1 + boost * 1.2) * direction * 4;
		
		rotation = direction * velocity.y * 0.01;
		
		if !flapping and flap_request:
			if velocity.y > 2:
				velocity.y = -6;
			else:
				velocity.y -= 7;
			boost = 1.0;
			if !hurting:
				anim.play("flap")
			flapping = true;
			flapped = false;
			flap_request = false;
			flap_released = false;
		else:
			if flap_down and flap_released:
				flap_request = true
				
		var dy = rope_attach_point.global_position.y - global_position.y;
		if dy > max_height_per_row:
			velocity.y += (dy - max_height_per_row) * 0.003

		
		if velocity.y > 0 and !flapping and !flapped and !flap_down and !hurting:
			anim.play("flap_down")
			flapped = true;
		
		velocity.y = clamp(velocity.y, -15, 30)
		#move_and_collide(velocity)
		var dv =  velocity * _delta * 60.0;
		position += dv
		
		cur_thread -= velocity.length() * 0.0075
		
		if (position.y >= floor_y):
			crash()
		elif cur_thread <= 0.0:
			thread_end()
		elif direction > 0 and position.x >= right_x:
			land_on_wall();
		elif direction < 0 and position.x <= left_x:
			land_on_wall();
	
	if state == State.Falling:
		velocity.y += gravity * gravity_scale;
		#velocity.x = -sign(direction) * 4;
		velocity.y = clamp(velocity.y, -15, 30)
		
		#move_and_collide(velocity)
		var dv =  velocity * _delta * 60.0;
		position += dv
		
		if velocity.x > 0 and position.x > right_x:
			velocity.x *= -0.5;
			position.x = right_x
		if velocity.x < 0 and position.x < left_x:
			velocity.x *= -0.5;
			position.x = left_x
		for i in range(rope_segments.size()):
			var r = rope_segments[i]
			var gpos = global_position
			if !is_instance_valid(r):
				continue
			if r.is_under(gpos):
				#print("UNDA")
				#r.queue_free()
				glide_rope_index = i
				land_on_rope()
		if (position.y >= floor_y):
			crash()
		pass
	
	if state == State.Gliding:
		var rope = rope_segments[glide_rope_index]
		#print(glide_vel)
		glide_vel += rope.dir_normalized.y * 0.3;
		
		velocity = rope.dir_normalized * glide_vel
		var dv =  velocity * _delta * 60.0;
		position += dv
		direction = sign(velocity.x)
		position.y = rope.get_position_at_x(position).y
		if position.x > rope.p_right.x:
			position.x = rope.p_right.x
			glide_rope_index -= 1;
			direction = -sign(rope.dir_normalized.x)
			_refresh()
			update_cam()
		if position.x < rope.p_left.x:
			position.x = rope.p_left.x
			glide_rope_index -= 1;
			direction = -sign(rope.dir_normalized.x)
			_refresh()
			update_cam()
		if glide_rope_index < 0:
			finish_glide();
	
	if state == State.Finished:
		velocity *= 0.92;
		var dv =  velocity * _delta * 60.0;
		position += dv
		rotation = 0
		if abs(velocity.x) > 0.1:
			anim.play("slide")
		else:
			anim.play("idle")
	pass

func finish_glide():
	state = State.Finished
	if velocity.x > 0: velocity = Vector2(5, 0)
	else: velocity = Vector2(-5, 0)
	cam.tween_offset(0, -30)
	position.y = spawn_pos.y

func thread_end():
	if state == State.Falling: return
	Game.hit_freeze(0.1)
	cam.shake()
	state = State.Falling
	velocity.y = -randf_range(1, 4)
	velocity.x = -direction * randf_range(7.0, 10.0)
	anim.play("threadout")
	pass

var glide_vel = 0.0;
func land_on_rope():
	state = State.Gliding;
	anim.play("glide")
	cam.deadzone_y = 10
	
	pass

func _on_anim_animation_finished(anim_name:String):
	if anim_name == "flap" or anim_name == "ouch":
		flapping = false;
		hurting = false;

func _on_collision_area_entered(node):
	if node is Item and !node.picked_up:
		node.pick_up()
		cur_thread += 7.0
		cur_thread = clamp(cur_thread, 0.0, thread_total)
		current_rope.attach_to_rope(node)
	elif node is Enemy:
		node.hurt(self)
		hurt()

