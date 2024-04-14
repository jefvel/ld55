extends Node2D
class_name Item;

@onready var sprite = $sprite
@onready var animation_player = $AnimationPlayer

var picked_up = false;

func _ready():
	sprite.frame = randi() % (sprite.hframes * sprite.vframes);
	
func pick_up():
	picked_up = true;
	animation_player.play("pickup")

var time: float = 0.0 + randf();
func _physics_process(delta):
	if !picked_up and !Game.frozen:
		time += delta * 2;
		sprite.position.y = round(sin(time) * 2.9)
	else:
		sprite.position.y = 0
