extends Node2D
@onready var animation_player = $AnimationPlayer
func _ready():
	animation_player.play("spawn")
	audio_stream_player.play()
@onready var audio_stream_player = $AudioStreamPlayer
