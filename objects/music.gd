extends Node

@onready var fly_music = $FlyMusic
@onready var fast_music = $FastMusic

func _on_bird_on_start_flying():
	fly_music.play()
	#fast_music.play()
	#fast_music.volume_db = -999999.0;
	pass # Replace with function body.


func _on_bird_on_died():
	fly_music.stop()
	fast_music.stop()
	pass # Replace with function body.

var vol_tw: Tween;
var fallin = false
func _on_bird_on_start_falling():
	if fallin: return
	fallin = true
	vol_tw = get_tree().create_tween()
	vol_tw.tween_property(fly_music, "volume_db", -12, 0.3)
	pass # Replace with function body.

var glidin = false
func _on_bird_on_start_gliding():
	if glidin: return
	glidin = true
	vol_tw = get_tree().create_tween()
	vol_tw.tween_property(fly_music, "volume_db", -99999, 0.1)
	fast_music.play()
