extends Sprite2D

@export var target: Node2D;
@export var collected: bool;
@export_range(0.0, 1.0) var friction = 0.9;

var velocity: Vector2;

signal on_picked_up;

func _ready() -> void:
	velocity = Vector2.from_angle(randf() * TAU) * randf_range(1.0, 10.0)

func _physics_process(delta: float) -> void:
	position += velocity;
	velocity *= friction;
	
	pass

