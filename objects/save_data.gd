extends Node

var rounds_played: int = 0;
var deaths: int = 0;

var small_orbs: int = 0;
var med_orbs: int = 0;
var large_orbs: int = 0;

func _ready() -> void:
	add_to_group("CloudSave")

func _cloud_save():
	return {
		"rounds_played": rounds_played,
		"deaths": deaths,
		"small_orbs": small_orbs,
		"med_orbs": med_orbs,
		"large_orbs": large_orbs,
	}
