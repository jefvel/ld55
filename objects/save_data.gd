extends Node

var rounds_played: int = 0;

func _ready() -> void:
	add_to_group("CloudSave")

func _cloud_save():
	return {
		"rounds_played": rounds_played
	}
