extends Node2D

@onready var bg = $BgLayer/bg
@onready var camera = $World/Camera

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
func intoPot(level: int = 1):
	total += 1;
	var sprite = $World/Cauldron/sprite
	sprite.rotation = randf_range(0.01, -0.01);
	var t = get_tree().create_tween().set_trans(Tween.TRANS_ELASTIC)
	t.tween_property(sprite, "rotation", 0, 0.1)
	left -= 1;
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
			if blobs.size() > 0:
				var blob = blobs[0];
				blobs.remove_at(0)
				if !is_instance_valid(blob):return
				
				blob.global_position = spatula.global_position
				blob.position.y -= 400.0;
				blob.position.x += randf_range(-40, 40)
				blob.velocity = Vector2(0, 0.1)
				blob.putting_into_pot = true
				left += 1
				blob.on_put_into_pot.connect(intoPot)
			
			
@onready var ui = $UILayer/UI

func to(d: float = 0.5):
	return get_tree().create_timer(d).timeout
	
var required_birds = 10.0;
var current_birds = 0.0;
var fff = false
func finish():
	if fff:return
	fff = true
	
	if total == 0:
		enable_retry()
		return
	
	await to(1.0)
	ui.flash()
	$World/Cauldron/sprite/AudioStreamPlayer.play()
	await to(0.6)
	bar.showw()
	await to(0.4)
	
	
	for i in range(total):
		spawn_bird();
		if total > 50:
			await to(0.05)
		else: await to(0.1)
		pass
	
	if current_birds >= required_birds:
		show_win();
	else:
		enable_retry()
	
	pass
@onready var bar = $World/Cauldron/sprite/bar

const SMALL_BIRD = preload("res://objects/small_bird.tscn")
func spawn_bird():
	var b = SMALL_BIRD.instantiate()
	items.add_child(b)
	b.global_position = spatula.global_position
	b.position.y -= 2;
	b.position.x += randf_range(-90, 90)
	current_birds += 1;
	bar.value = (current_birds / required_birds)
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
	blobs = bird.punched_slugs
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
