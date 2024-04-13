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

var thread_total = 100.0;
var cur_thread = 100.0;

var rope_segments: Array[Rope]
var current_rope: Rope;

var max_height_per_row = 300.0;

@export var left_x = -666;
@export var right_x = 999 + 333;

var floor_y = 600;

enum State {
	Idle,
	Sitting,
	Flying,
	Gliding,
	Crashed,
}

var state: State = State.Idle;

var flapping = false;
var flapped = false;

var boost = 0.0;

# <-1     1 >
var direction: int = 1 if randf() > 0.5 else -1;

func _ready():
	var spawns = get_tree().get_nodes_in_group("PlayerSpawn").pick_random()
	global_position = spawns.global_position
	anim.play("idle")
	_refresh();
	_create_rope();
	
@onready var rope_end = $rope_end

func _create_rope():
	var rope = Rope.new()
	rope_container_node.add_child(rope)
	rope.end_node = rope_end;
	rope.start_node = rope_attach_point
	rope_segments.push_back(rope)
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
			
		velocity.y = clamp(velocity.y, -15, 30)
		
		if velocity.y > 0 and !flapping and !flapped and !flap_down:
			anim.play("flap_down")
			flapped = true;
			
		#move_and_collide(velocity)
		var dv =  velocity * _delta * 60.0;
		position += dv
		
		cur_thread -= velocity.length() * 0.01
		
		if (position.y >= floor_y):
			crash()
		elif direction > 0 and position.x >= right_x:
			land_on_wall();
		elif direction < 0 and position.x <= left_x:
			land_on_wall();
	pass


func _on_anim_animation_finished(anim_name:String):
	if anim_name == "flap":
		flapping = false;

func _on_collision_area_entered(node):
	if node is Item and !node.picked_up:
		node.pick_up()
		cur_thread += 7.0
		cur_thread = clamp(cur_thread, 0.0, thread_total)
		current_rope.attach_to_rope(node)

