extends Node2D
class_name Rope;

@export var start_node: Node2D;
@export var end_node: Node2D;

var attached_objects: Array[Node2D] = [];
var attached_lengths: Array[float] = [];

var p0: Vector2;
var p1: Vector2;

func attach_to_rope(object: Node2D):
	var d = object.global_position - p0;
	var l = d.length()
	attached_objects.push_back(object)
	attached_lengths.push_back(l)
	pass
	
func reposition_items():
	var d = (p1 - p0).normalized()
	for i in range(attached_objects.size()):
		attached_objects[i].global_position = d * attached_lengths[i] + p0
	pass

func _physics_process(delta):
	var np0 = start_node.global_position;
	var np1 = end_node.global_position
	if np0.distance_squared_to(p0) > 0 or np1.distance_squared_to(p1) > 0:
		p0 = np0
		p1 = np1
		queue_redraw()
		reposition_items();

func _draw():
	draw_line(p0, p1, Color.WHITE, 1)
	pass
