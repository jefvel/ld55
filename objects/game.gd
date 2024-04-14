extends Node

var enemy_node: Node2D;
var can_start = true;
var bird: Bird;

var frozen: bool:
	get: return freeze_time > 0

var freeze_time = 0.0;

func hit_freeze(time: float= 0.1):
	freeze_time = time;
	
func _physics_process(delta):
	if freeze_time > 0.0:
		freeze_time -= delta;
	pass
	
