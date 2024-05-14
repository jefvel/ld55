extends Node2D
class_name Bird;

@onready var anim = $anim
@onready var sprite = $Sprite

@export var cam: GameCamera;

@export var gravity: float = 0.4;
var velocity: Vector2

signal on_start_flying;
signal on_hit_wall;
signal on_start_falling;
signal on_start_gliding;
signal on_wand_dropped;
signal on_landed;
signal on_died;

var score: int = 0;
var combo: int = 1;

@export var rope_attach_point: Node2D;
@export var rope_container_node: Node2D;

var initial_attach_point: Node2D

var thread_total = 45.0;
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
	Game.bird = self;
	var spawns = get_tree().get_nodes_in_group("PlayerSpawn").pick_random()
	spawn_pos = spawns.global_position
	global_position = spawns.global_position
	initial_attach_point = rope_attach_point
	anim.play("idle")
	_refresh();
	_create_rope();
	
@onready var rope_end = $Sprite/hand/rope_end

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
	var first_jump = state == State.Idle
	state = State.Flying;
	update_cam()
	cam.deadzone_y = 85.0;
	
	if first_jump:
		on_start_flying.emit()
	pass

func crash():
	rotation = 0;
	state = State.Crashed
	position.y = floor_y
	anim.play("dead")
	drop_wand()
	on_died.emit();
	$audio/crash.play()
	#Game.hit_freeze(0.1)
	slugify_enemies(0)
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
	
	slugify_enemies()
	
	var n = ROSETTE.instantiate()
	if direction < 0:
		n.scale.x = -1;
	get_parent().add_child(n)
	rope_end.global_position.x = global_position.x
	n.global_position = rope_end.global_position
	current_rope.end_node = n
	rope_attach_point = n
	_create_rope()
	
	on_hit_wall.emit();

func slugify_enemies(timescale = 1.0):
	var de = 0.4 * timescale;
	for e in collected_enemies:
		e.turn_into_slug(de)
		de += 0.1 * timescale;
	collected_enemies.clear()

var hurt_time = 0.0;
@onready var hurt_sounds = [$audio/hurt1, $audio/hurt2, $audio/hurt3]
func hurt():
	# combo = 0;
	hurting = true;
	hurt_time = 0.1
	cur_thread -= 10.0;
	anim.play("ouch")
	Game.hit_freeze()
	cam.shake()
	var snd = hurt_sounds.pick_random()
	snd.pitch_scale = randf_range(0.99, 1.02)
	snd.play()

const ROSETTE = preload("res://objects/rosette.tscn")
func _refresh():
	if direction < 0:
		sprite.scale.x = -1;
	elif direction > 0:
		sprite.scale.x = 1;
		
func flap():
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
	flap_sfx.play()
	flap_sfx.pitch_scale = randf_range(0.98, 1.05)
@onready var flap_sfx = $audio/flap
	
var flap_request = false;
var flap_released = false;
var time_since_punch_press = 100.0;
func _physics_process(_delta):
	time_since_punch_press += _delta;
	var flap_pressed = Input.is_action_just_pressed("FLAP")
	var flap_down = Input.is_action_pressed("FLAP")
	
	if !flap_down:
		flap_released = true;
		
	if flap_pressed:
		time_since_punch_press = 0.0;
	if Game.frozen:
		punch_time -= _delta
		#particles.speed_scale = 0.1;
		smash.speed_scale = 0.1
		return
	else:
		smash.speed_scale = 1.0
		#particles.speed_scale = 1.0;
	
	_refresh()
	if flap_pressed:
		if state == State.Idle or state == State.Sitting:
			if state == State.Idle and !Game.can_start: return
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
			flap()
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
		
		if rope_segments.size() > 0:
			var top_rope = rope_segments[-1]
			var pos = position;
			pos.y -= 32.0;
			if is_instance_valid(top_rope):
				if top_rope.is_under(pos):
					top_rope.snap_off()
					rope_segments.remove_at(rope_segments.size() - 1)
					if rope_segments.size() > 0:
						var np = rope_segments[-1]
						current_rope.start_node = np.start_node
						np.snap_off()
						rope_segments.remove_at(rope_segments.size() - 1)
					else:
						current_rope.start_node = initial_attach_point
				
		
		if (position.y >= floor_y):
			crash()
		elif cur_thread <= 0.0:
			thread_end()
		elif direction > 0 and position.x >= right_x:
			land_on_wall();
		elif direction < 0 and position.x <= left_x:
			land_on_wall();
	
	if state == State.Falling:
		velocity.y += gravity * gravity_scale * 0.7;
		#velocity.x = -sign(direction) * 4;
		velocity.y = clamp(velocity.y, -15, 30)
		
		#move_and_collide(velocity)
		var dv =  velocity * _delta * 60.0;
		position += dv
		
		if velocity.x > 0 and position.x > right_x - 40:
			velocity.x *= 0.5;
			position.x = min(position.x, right_x - 20)
		if velocity.x < 0 and position.x < left_x + 40:
			velocity.x *= 0.5;
			position.x = max(position.x, left_x + 20)
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
		glide_time += _delta
		if glide_time > 0.8: glide_vel = max(glide_vel, 6.0)
		var rope = rope_segments[glide_rope_index]
		#print(glide_vel)
		#glide_vel += rope.dir_normalized.y * 0.2;
		glide_vel = clamp(glide_vel, 0.0, 20.0)
		
		if hurting:
			hurt_time -= _delta
			if hurt_time <= 0: hurting = false;
		
		var rot = rope.dir_normalized.angle()
		rotation = rot + PI
		if direction > 0:
			rotation += PI
		
		velocity = rope.dir_normalized * glide_vel
		var dv =  velocity * _delta * 60.0;
		position += dv
		direction = sign(velocity.x)
		position.y = rope.get_position_at_x(position).y
		if position.x > rope.p_right.x:
			position.x = rope.p_right.x
			direction = -sign(rope.dir_normalized.x)
			glide_switch_dir()
		if position.x < rope.p_left.x:
			position.x = rope.p_left.x
			direction = -sign(rope.dir_normalized.x)
			glide_switch_dir()
		if glide_rope_index < 0:
			finish_glide();
		
		
		if !punching and time_since_punch_press < 0.15:
			punch()
		if punching:
			anim.play("slap")
			punch_time -= _delta
			if punch_time > 0.04:
				for slug in get_tree().get_nodes_in_group("Slug"):
					if slug is RopeBlob:
						if slug.dead: continue
						if slug.hit_player: continue
						var d = slug.position - position;
						var slap_range = 58.0;
						if d.length_squared() < slap_range * slap_range:
							if d.normalized().dot(velocity.normalized()) > 0.6:
								#slug.queue_free()
								slug.punch();
								
								particles.reparent(get_parent())
								particles.emitting = true;
								
								particles.global_position = smash_particle.global_position;
								
								particles.rotation = sprite.rotation + randf_range(-0.01,0.01)
								smash.restart()
								if sprite.scale.x < 0:
									particles.rotation += PI
								particles.restart();
								
								add_score(slug.level * 200)
								combo += slug.level
								punched_slugs.push_back(slug)
								punchsfx.play()
								punchsfx.pitch_scale = randf_range(0.99, 1.02)
								Game.hit_freeze()
								cam.shake()
								pass
						pass
			
			if punch_time <= 0:
				punching = false;
		elif !hurting: 
			anim.play("glide")
	
	if state == State.Finished:
		velocity *= 0.92;
		var dv =  velocity * _delta * 60.0;
		position += dv
		rotation = 0
		if abs(velocity.x) > 0.1:
			anim.play("slide")
		else:
			anim.play("idle")
			finish_landing();
	pass

@onready var smash_particle: Node2D = $Sprite/SmashParticle
@onready var particles: CPUParticles2D = $Sprite/SmashParticle/Particles
@onready var smash: CPUParticles2D = $Sprite/SmashParticle/Particles/smash

var glide_time = 0.0

func finish_landing():
	if landed : return
	landed = true
	on_landed.emit()

var landed = false;
var punched_slugs: Array[RopeBlob] = [];
var punching = false;
var punch_time = 0.1;
func punch(): 
	if punching: return
	time_since_punch_press = 1000.0
	punch_time = 0.13;
	anim.stop()
	anim.play("slap")
	punching = true;
	swingsfx.play()
	swingsfx.pitch_scale = randf_range(0.99, 1.02)
	
	pass
@onready var swingsfx = $audio/swing
@onready var punchsfx = $audio/punch

func glide_switch_dir():
	glide_rope_index -= 1;
	glide_vel += 0.9;
	_refresh()
	update_cam()
	pass

func finish_glide():
	state = State.Finished
	if velocity.x > 0: velocity = Vector2(5, 0)
	else: velocity = Vector2(-5, 0)
	cam.tween_offset(0, -30)
	position.y = spawn_pos.y
	finish_landing()

func drop_wand():
	if wand.dropped: return
	var wandpos = wand.global_position;
	wand.reparent(get_parent())
	wand.global_position = wandpos
	wand.drop();
	on_wand_dropped.emit()

func thread_end():
	if state == State.Falling: return
	state = State.Falling
	slugify_enemies()
	Game.hit_freeze(0.1)
	$audio/spring.play()
	drop_wand()
	
	cam.shake()
	cam.tween_offset(0.0, 0.0)
	
	if is_instance_valid(current_rope):
		current_rope.snap_off()
		current_rope = null
	
	for e in get_tree().get_nodes_in_group("Enemy"):
		if e is Enemy:
			e.fade_out()
	
	for i in get_tree().get_nodes_in_group("Item"):
		if i is Item:
			i.prepare()
	
	velocity.y = -randf_range(8, 9)
	velocity.x = -direction * randf_range(18, 23.0)
	anim.play("threadout")
	on_start_falling.emit()
	pass

@onready var wand = $Sprite/hand/wand

var glide_vel = 0.001;
func land_on_rope():
	state = State.Gliding;
	anim.play("glide")
	cam.deadzone_y = 10
	
	update_cam()
	
	on_start_gliding.emit()
	pass

var collected_enemies: Array[Enemy] = []
func get_queue_position(i):
	if i < 0: return position
	if i >= collected_enemies.size():
		return position
	return collected_enemies[i].position
func enemy_collected(e: Enemy):
	collected_enemies.push_back(e)
	e.collect_queue_index = collected_enemies.size() - 1
	pass

func _on_anim_animation_finished(anim_name:String):
	if anim_name == "flap" or anim_name == "ouch":
		flapping = false;
		hurting = false;
@onready var pickupsfx = $audio/pickup

func add_score(s:int):
	# score += s * (1 + combo)
	pass

var pickups  =0
func _on_collision_area_entered(node):
	if state == State.Gliding:
		if node is RopeBlob:
			if node.dead:
				return
			node.hit_player = true;
			hurt()
		pass
	if node is EnemyHitbox:
		if node.target is Enemy and !node.target.dead:
			node.target.hurt(self)
			hurt()
		elif node.target is Item:
			var item:Item = node.target;
			if !is_instance_valid(current_rope): return
			if item.picked_up: return
			item.pick_up()
			add_score(50)
			pickups += 1;
			#combo += 1
			pickupsfx.play()
			pickupsfx.pitch_scale = randf_range(0.99, 1.02)
			cur_thread += 7.0
			cur_thread = clamp(cur_thread, 0.0, thread_total)
			#current_rope.attach_to_rope(item)
