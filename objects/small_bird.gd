extends Node2D
@onready var animation_player = $AnimationPlayer
@onready var audio_stream_player = $AudioStreamPlayer

@export var bird_name: String;


func _ready():
	animation_player.play("spawn")
	audio_stream_player.play()
	
