extends Control

@onready var bar = $sprite/bar
@export var value: float = 0.5:
	set(v):
		value = v
		if !bar: return
		bar.size.y = 21 * clamp(v, 0.0, 1.0)
		bar.position.y = sy + (h - bar.size.y)

var h = 21
var sy = 6;

func _ready():
	value = value
	
