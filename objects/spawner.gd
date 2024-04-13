extends Node2D

@export var player: Bird;
@export var left_wall: Node2D;
@export var right_wall: Node2D;

@export var item_layer: Node2D;

const ITEM = preload("res://objects/item.tscn")

const GHOST = preload("res://objects/enemies/ghost.tscn")
const EVIL_EYE = preload("res://objects/enemies/evil_eye.tscn")

const formations = [
	preload("res://objects/formations/line.tscn"),
	preload("res://objects/formations/oneenemy.tscn"),
	preload("res://objects/formations/square.tscn"),
	preload("res://objects/formations/square2.tscn"),
]

func spawn():
	var end_point: Vector2;
	end_point.x = left_wall.global_position.x if player.direction < 0 else right_wall.global_position.x
	end_point.y = player.global_position.y - randf_range(50, 150)
	
	var start_point = player.global_position;
	var dz = 150.0;
	var len = dz;
	
	var dir = sign(end_point.x - start_point.x)
	var d = (end_point - start_point)
	var total_len = d.length();
	
	var max_spawns = 6;
	var h_length = abs(end_point.x - start_point.x)
	var min_spawns = 2;
	if h_length < 1200:
		max_spawns = 2;
		min_spawns = 1

	var items_to_spawn = randi_range(min_spawns, max_spawns)

	var dd = d.normalized()

	for i in range(items_to_spawn):
		var item = formations.pick_random().instantiate()
		len += randf_range(180, 450)
		print(total_len- dz)
		if len > total_len - dz:
			break
		item_layer.add_child(item)
		item.global_position = start_point + dd * len
		item.position.y -= randf_range(50, 150)
		pass
	pass
