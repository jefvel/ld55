extends Node2D
@onready var bar = $bar

@export var value = 0.0;
func _ready():
	pass
func showw():
	$AnimationPlayer.play("show")
func _physics_process(delta):
	var v = clamp(value, 0.0, 1.0)
	bar.scale.x = v * 30.0
