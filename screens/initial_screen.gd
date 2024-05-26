extends Control
func _on_sign_in_form_on_sign_in_skipped() -> void:
	call_deferred("goto_game")
func _on_sign_in_form_on_signed_in() -> void:
	call_deferred("goto_game")

func goto_game():
	var tree = get_tree()
	tree.change_scene_to_file("res://main.tscn")
