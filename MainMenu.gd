extends Node

@export var nextScene : PackedScene


func _on_butt_new_g_button_up():
	get_tree().change_scene_to_file(nextScene.resource_path)