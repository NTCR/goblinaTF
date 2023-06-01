extends Node

@export_file var next_scene
@export_category("Components:")
@export var parallax : ParallaxBackground
@export var transitions : AnimationPlayer

func _ready():
	parallax.set_motion(-6)
	parallax.start()

func _on_butt_new_game_pressed():
	transitions.play("to_merge")

func to_merge_scene():
	get_tree().change_scene_to_file(next_scene)
