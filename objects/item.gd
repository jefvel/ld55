extends Node2D
class_name Item;

@onready var anim = $anim
@onready var sprite = $sprite

func _ready():
	sprite.frame = randi() % (sprite.hframes * sprite.vframes);


var time: float = 0.0 + randf();
func _physics_process(delta):
	time += delta * 2;
	sprite.position.y = round(sin(time) * 2.9)
