extends Node2D

@onready var bg = $BgLayer/bg
@export var camera:GameCamera

@onready var spawner = $Spawner
@onready var bird = $World/Bird


func _ready():
	DisplayServer.window_set_min_size(Vector2i(888,666))
	spawner.spawn()

func _process(_D):
	var pos = round(camera.position * 0.98 + camera.offset);
	bg.material.set_shader_parameter("offset", pos)
	
@onready var spatula = $World/Cauldron/sprite/spatula
@onready var items = $World/Items

var finished = false;
var until_drop = 1.0;
var total = 0;
var left = 0;

var total_blob_score = 0;
var base_score = 0;
func intoPot(level: int = 1):
	var sprite = $World/Cauldron/sprite
	sprite.rotation = randf_range(0.01, -0.01);
	var t = get_tree().create_tween().set_trans(Tween.TRANS_ELASTIC)
	t.tween_property(sprite, "rotation", 0, 0.1)
	left -= 1;
	var scr = bird.pickups

	bird.pickups += base_score * level;
	bird.combo -= level;
	total = bird.pickups
	if left <= 0:
		finish();
	pass

func _physics_process(delta):
	if OS.is_debug_build():
		if Input.is_action_just_pressed("Win"):
			total = 10
			_on_bird_on_landed()
	if Input.is_action_just_pressed("Reset"):
		get_tree().reload_current_scene()
	
	if can_retry and Input.is_action_just_pressed("FLAP"):
		get_tree().reload_current_scene()
	if finished and !fff:
		until_drop -= delta;
		if until_drop <= 0:
			until_drop = 0.15;
			if blobs.size() > 25:
				until_drop = 0.05
			if blobs.size() > 50:
				until_drop = 0.02
			elif blobs.size() > 10:
				until_drop = 0.1
			if blobs.size() > 0:
				var blob = blobs[0];
				blobs.remove_at(0)
				if !is_instance_valid(blob):return
				
				blob.global_position = spatula.global_position
				blob.position.y = -300.0;
				blob.position.x += randf_range(-60, 60)
				blob.velocity = Vector2(0, 0.1)
				blob.putting_into_pot = true
				left += 1
				total_blob_score += blob.level
				blob.on_put_into_pot.connect(intoPot)
			
			
@onready var ui = $UILayer/UI

func to(d: float = 0.5):
	return get_tree().create_timer(d).timeout
	
var required_score = 200.0;
var current_birds = 0.0;
var fff = false
@onready var cauldron: Node2D = $World/Cauldron

func finish():
	if fff:return
	fff = true
	
	SaveData.rounds_played += 1;
	
	if total == 0:
		enable_retry()
		return
	
	await to(0.5)
	cauldron.start_shaking()
	await cauldron.finished_shaking;
	ui.flash()
	cauldron.erupt();
	camera.shake()
	await to(0.6)
	bar.showw()
	await to(0.4)
	NG.scoreboard_submit(NewgroundsIds.ScoreboardId.BestSoup, bird.pickups)
	
	#var bird_count = max(1, floor(float(total) / 10.0))
	#for i in range(bird_count):
	while total > 0:
		spawn_bird();
		if total > 50:
			await to(0.05)
		else: await to(0.1)
		pass
	
	if current_birds >= required_score:
		show_win();
	else:
		enable_retry()
	pass

@onready var bar = $World/Cauldron/sprite/bar
const BIG_BIRD = preload("res://objects/big_bird.tscn")
const SMALL_BIRD = preload("res://objects/small_bird.tscn")
func spawn_bird():
	var b
	if total >= 150:
		b = BIG_BIRD.instantiate()
		total -= 150
		current_birds += 150
	elif total >= 10:
		total -= 10;
		current_birds += 10
		b = SMALL_BIRD.instantiate()
	else:
		total = 0
		return
	items.add_child(b)
	b.global_position = spatula.global_position
	b.position.y -= 2;
	b.position.x += randf_range(-90, 90)
	bar.value = (current_birds / required_score)
	pass

func _on_bird_on_hit_wall():
	spawner.spawn()
	pass # Replace with function body.

func show_win():
	await to(0.7)
	ui.show_win(current_birds, bird.score)
	await to(0.2)
	can_retry = true
	pass

var blobs: Array[RopeBlob] = []
func _on_bird_on_landed():
	finished = true;
	base_score = bird.pickups
	blobs = bird.punched_slugs
	var b_pos = bird.global_position
	bird.reparent($World/Cauldron/sprite)
	bird.global_position = b_pos
	if blobs.size() == 0:
		await to(0.5)
		finish()
	pass # Replace with function body.


func enable_retry():
	await to(0.3)
	can_retry = true
	await to(0.7)
	ui.show_retry()
	pass

var can_retry = false;
func _on_bird_on_died():
	enable_retry()
	pass # Replace with function body.
