extends Node2D
class_name Rope;

@export var start_node: Node2D;
@export var end_node: Node2D;

func _physics_process(delta):
	queue_redraw()

func _draw():
	draw_line(start_node.global_position, end_node.global_position, Color.WHITE, 1)
	pass
