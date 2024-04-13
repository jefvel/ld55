extends Node2D

enum EnemyType {
	Ghost,
	EvilEye,
}

const EVIL_EYE = preload("res://objects/enemies/evil_eye.tscn")
const GHOST = preload("res://objects/enemies/ghost.tscn")

@export var enemy_type: Array[EnemyType];

func get_enemy():
	var e = enemy_type.pick_random()
	match e:
		EnemyType.Ghost:
			return GHOST;
		EnemyType.EvilEye:
			return EVIL_EYE;

func _ready():
	var n = get_enemy().instantiate();
	n.global_position = global_position;
	queue_free()
	pass
