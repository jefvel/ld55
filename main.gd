extends Node2D

@onready var bg = $BgLayer/bg
@onready var camera = $World/Camera

func _process(_D):
	var pos = round(camera.position * 0.98 + camera.offset);
	#bg.position = round(pos - get_viewport_rect().size * 0.5);
	bg.material.set_shader_parameter("offset", pos)
	

func _physics_process(delta):

	
	if Input.is_action_just_pressed("Reset"):
		get_tree().reload_current_scene()
