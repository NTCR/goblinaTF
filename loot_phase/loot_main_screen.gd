extends Node

@export_file var next_scene
@export var transitions : AnimationPlayer
@export var fadeblack : ColorRect

func _ready():
	fadeblack.visible = true
	transitions.play("enter_merge")

func start_phase():
	get_tree().call_group("crates", "set_process_input", true)

func end_phase():
	get_tree().call_group("crates", "set_process_input", false)
	transitions.play("to_shop")

func to_shop_scene():
	get_tree().change_scene_to_file(next_scene)
