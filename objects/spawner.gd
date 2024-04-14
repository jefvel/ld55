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
	preload("res://objects/formations/square3.tscn"),
	preload("res://objects/formations/square4.tscn"),
]

var spawned = 0;

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
	var min_dist = 180.0;
	var max_spawns = 3;
	
	var h_length = abs(end_point.x - start_point.x)
	var min_spawns = 2;
	if h_length < 1200:
		max_spawns = 2;
		min_spawns = 1
	
	if spawned > 5:
		max_spawns = 4
	if spawned > 10:
		max_spawns = 5;
	if spawned > 20:
		max_spawns += 1
	if spawned > 6:
		min_dist -= 1.0
	
	min_dist = max(min_dist, 100);
	
	var items_to_spawn = randi_range(min_spawns, max_spawns)

	var dd = d.normalized()
	spawned += 1
	for i in range(items_to_spawn):
		var item = formations.pick_random().instantiate()
		len += randf_range(min_dist, 450)
		# print(total_len- dz)
		if len > total_len - dz:
			break
		item_layer.add_child(item)
		item.global_position = start_point + dd * len
		item.position.y -= randf_range(50, 150)
		pass
	pass
