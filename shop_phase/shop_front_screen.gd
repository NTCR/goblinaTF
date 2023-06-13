extends Node

@export_file var next_scene
@export var transitions : AnimationPlayer

func _ready():
	TransitionManager.first_enter_shop = false
	if TransitionManager.first_enter_shop:
		transitions.play("to_storage")
	else:
		transitions.play("to_sell")
		TransitionManager.first_enter_shop = false

func go_storage():
	TransitionManager.first_enter_shop = false
	get_tree().change_scene_to_file(next_scene)

func begin_sell():
	print("sell would start")
