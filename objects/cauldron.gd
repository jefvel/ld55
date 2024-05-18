extends Node2D

@onready var anim: AnimationPlayer = $CauldronAnim
@onready var rumble_sfx: AudioStreamPlayer = $rumble_sfx
@onready var erupt_sfx: AudioStreamPlayer = $erupt_sfx

signal finished_shaking;
@export var shaking = false;
@export var shake_power = 0.0;

func _finished_shaking():
	finished_shaking.emit();

func start_shaking():
	anim.play("shake")

func erupt():
	anim.play("erupt")
	pass
	
@onready var cauldron: Sprite2D = $sprite
	
var dt = 0.0;
func _physics_process(delta: float) -> void:
	if shaking:
		dt += delta
		cauldron.rotation = sin(dt * 100) * 0.01 * shake_power
		pass

func stop_shaking():
	anim.play("RESET");
