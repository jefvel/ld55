extends Control

@export var bird: Bird;

@onready var thread_bar = $ThreadBar
@onready var color_rect = $ColorRect
@onready var uianim = $uianim

func format_number(number: int) -> String:
	# Handle negative numbers by adding the "minus" sign in advance, as we discard it
	# when looping over the number.
	var formatted_number := "-" if sign(number) == -1 else ""
	var index := 0
	var number_string := str(abs(number))

	for digit in number_string:
		formatted_number += digit

		var counter := number_string.length() - index

		# Don't add a comma at the end of the number, but add a comma every 3 digits
		# (taking into account the number's length).
		if counter >= 2 and counter % 3 == 1:
			formatted_number += ","

		index += 1

	return formatted_number
@onready var scoretxt = $Score
@onready var combo = $Score/combo
	
func _ready():
	Game.can_start =true
	color_rect.visible = true;
	var t = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	t.tween_property(color_rect, "modulate:a", 0, 0.2)
	t.finished.connect(_finish)
	uianim.play("RESET")

func _physics_process(delta):
	thread_bar.value = (bird.cur_thread / bird.thread_total)
	scoretxt.text = format_number(bird.pickups)
	#scoretxt.text = "test text 1023\ntest row 2"
	if bird.combo > 1:
		combo.text = 'X%s' % int(bird.combo)
	else: combo.text = ''

func _finish():
	color_rect.visible = false;
	pass
func flash():
	uianim.play("flash")
func show_retry():
	uianim.play("show_retry")
func _on_bird_on_start_flying():
	thread_bar.appear()
	uianim.play("start_game")
	pass # Replace with function body.

func show_win(birdcount = 0, score = 0):
	$win/ColorRect/TextureRect/Label2.text = 'Score %s\nSummoned %s Friends' % [format_number(bird.pickups), format_number(birdcount)]
	#$win/AudioStreamPlayer.play()
	uianim.play("showwin")
	pass

func _on_bird_on_wand_dropped():
	thread_bar.disappear()
	pass # Replace with function body.

var hovelink =false
func _on_link_button_mouse_entered():
	hovelink = true
	Game.can_start = false
	pass # Replace with function body.

func _on_link_button_mouse_exited():
	hovelink = false
	Game.can_start = true
	pass # Replace with function body.
