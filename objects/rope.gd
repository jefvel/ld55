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
	
var p_left = p0 if p0.x < p1.x else p1
var p_right = p1 if p1.x > p0.x else p0
var p_d : Vector2;
var dir_normalized: Vector2;
func _physics_process(delta):
	
	var np0 = start_node.global_position;
	var np1 = end_node.global_position
	if np0.distance_squared_to(p0) > 0 or np1.distance_squared_to(p1) > 0:
		p0 = np0
		p1 = np1
		
		queue_redraw()
		reposition_items();
		
		p_left = p0 if p0.x < p1.x else p1
		p_right = p1 if p1.x > p0.x else p0
		
		dir_normalized = (p0 - p1).normalized()
		#print(dir_normalized)
		p_d = (p_right - p_left).normalized()

func _draw():
	draw_line(p0, p1, Color.WHITE, 1)
	pass

var snapped = false;
func snap_off():
	if snapped: return
	snapped = true
	
	for i in attached_objects:
		if i is Item:
			i.drop()
	
	queue_free()
	pass

func get_position_at_x(po:Vector2) :
	var pos = p_left + p_d.dot(po - p_left) * p_d
	return pos

func is_under(p: Vector2):
	var min_y = min(p0.y, p1.y)
	if p.y < min_y: return false;
	var min_x = min(p0.x, p1.x)
	var max_x = max(p0.x, p1.x)
	if min_x > p.x:
		return false;
	if max_x < p.x:
		return false;
	
	var pos = p_left + (p.x - p_left.x) * p_d
	var py = pos.y - p.y
	if py < 0: 
		return true
	return false

	
	
