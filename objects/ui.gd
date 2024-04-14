extends Control

@export var bird: Bird;

@onready var thread_bar = $ThreadBar
@onready var color_rect = $ColorRect
@onready var uianim = $uianim

func _ready():
	color_rect.visible = true;
	var t = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	t.tween_property(color_rect, "modulate:a", 0, 0.1)
	t.finished.connect(_finish)

func _physics_process(delta):
	thread_bar.value = (bird.cur_thread / bird.thread_total)

func _finish():
	color_rect.visible = false;
	pass


func _on_bird_on_start_flying():
	thread_bar.appear()
	uianim.play("start_game")
	pass # Replace with function body.


func _on_bird_on_wand_dropped():
	thread_bar.disappear()
	pass # Replace with function body.
