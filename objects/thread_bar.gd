extends Control
@onready var anim = $anim

@onready var bar = $sprite/bar
@export var value: float = 0.5:
	set(v):
		if v> value and anim: anim.play("increase")
		value = v

var h = 21
var sy = 6;

var cur_v: float = 1.0;

func _ready():
	value = value

func _physics_process(delta):
	cur_v = lerp(cur_v, value, 0.3)
func _process(delta):
	bar.size.y = round(21 * clamp(cur_v, 0.0, 1.0))
	bar.position.y = sy + (h - bar.size.y)
