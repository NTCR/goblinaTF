extends Node

@export_file var next_scene

func _on_butt_new_g_button_up():
	get_tree().change_scene_to_file(next_scene)
