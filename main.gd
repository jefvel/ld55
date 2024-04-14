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
	
func _physics_process(delta):
	if Input.is_action_just_pressed("Reset"):
		get_tree().reload_current_scene()

func _on_bird_on_hit_wall():
	spawner.spawn()
	pass # Replace with function body.
