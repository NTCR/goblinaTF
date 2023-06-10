extends Node

@export_file var next_scene
@export var transitions : AnimationPlayer

func _ready():
	TransitionManager.first_enter_shop = true
	if TransitionManager.first_enter_shop:
		entering_shop()

func entering_shop():
	transitions.play("enter_shop")

func go_storage():
	TransitionManager.first_enter_shop = false
	get_tree().change_scene_to_file(next_scene)
