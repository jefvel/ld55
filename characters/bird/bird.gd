extends CharacterBody2D

@onready var anim = $anim
@onready var sprite = $Sprite

@export var cam: GameCamera;

@export var gravity: float = 0.4;

signal on_start_flying;
signal on_hit_wall;
signal on_start_gliding;
signal on_landed;
signal on_died;

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
var direction: int = 1;

func _ready():
	var spawns = get_tree().get_nodes_in_group("PlayerSpawn").pick_random()
	global_position = spawns.global_position
	anim.play("idle")
	_refresh()

func start_flying():
	state = State.Flying;
	on_start_flying.emit()
	update_cam()
	pass

func crash():
	rotation = 0;
	state = State.Crashed
	position.y = floor_y
	anim.play("dead")
	on_died.emit();
	
func update_cam():
	var off_x = 100.0;
	const off_y = -16.0;
	if direction < 0:
		off_x = -off_x;
	cam.tween_offset(off_x, off_y)

func land_on_wall():
	if state == State.Sitting:
		return
	state = State.Sitting
	velocity.x = 0;
	velocity.y = 0;
	
	anim.play("wallsit")
	
	rotation = 0;
	
	if direction > 0:
		position.x = right_x + 1;
	else:
		position.x = left_x - 1
	
	direction = -direction;
	update_cam();

	on_hit_wall.emit();

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
	else:
		gravity_scale = 0.7;
		boost *= 0.99
		
	if state == State.Flying:
		velocity.y += gravity * gravity_scale;
		velocity.x = (1 + boost * 1.5) * direction * 4;
		
		rotation = direction * velocity.y * 0.01;
		
		if !flapping and flap_request:
			if velocity.y > 5:
				velocity.y = -5;
			else:
				velocity.y -= 10;
			boost = 1.0;
			anim.play("flap")
			flapping = true;
			flapped = false;
			flap_request = false;
			flap_released = false;
		else:
			if flap_down and flap_released:
				flap_request = true
			
		velocity.y = clamp(velocity.y, -15, 30)
		
		if velocity.y > 0 and !flapping and !flapped and !flap_down:
			anim.play("flap_down")
			flapped = true;
			
		move_and_collide(velocity)
		
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
