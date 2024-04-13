extends Node2D
@onready var bird = $"../Bird"

func _process(delta):
	position.y = bird.position.y
