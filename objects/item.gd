extends Node2D
class_name Item;

@onready var sprite = $sprite
@onready var animation_player = $AnimationPlayer

var picked_up = false;

var falling = false;
var velocity: Vector2;

func _ready():
	sprite.frame = randi() % (sprite.hframes * sprite.vframes);
	
func pick_up():
	sprite.position.y = 0;
	var tw = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tw.tween_property(sprite, "position:y", -16, 1.8)
	picked_up = true;
	animation_player.play("pickup")

func drop():
	falling = true;
	pass
	
func prepare():
	if picked_up:
		animation_player.play("prepare")
	else:
		drop();

var time: float = 0.0 + randf();
func _physics_process(delta):
	if !picked_up and !Game.frozen:
		time += delta * 2;
		sprite.position.y = round(sin(time) * 2.9)
	
	if falling:
		velocity.y += 0.1;
		position += velocity;
		modulate.a *= 0.9;
		if modulate.a < 0.05:
			queue_free()
	#else:
		#sprite.position.y = 8
