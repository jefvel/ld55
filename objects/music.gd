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
func _on_bird_on_start_falling():
	vol_tw = get_tree().create_tween()
	vol_tw.tween_property(fly_music, "volume_db", -19, 0.3)
	pass # Replace with function body.



func _on_bird_on_start_gliding():
	vol_tw = get_tree().create_tween()
	vol_tw.tween_property(fly_music, "volume_db", -99999, 0.1)
	#vol_tw.tween_property(fast_music, "volume_db", -4, 0.1)
	fast_music.play()
	pass # Replace with function body.
