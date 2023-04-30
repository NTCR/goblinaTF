extends Node

@export_category("Child scenes:")
@export var merge_system : Node
@export var spawner : Node
@export var progress_bar : ProgressBar
@export var animation_transition : AnimationPlayer
@export_category("Next scene:")
@export var next_scene : PackedScene

# Prepare for next scene
func _transition_to_shop():
	#store loot
	LootDB.save_loot(merge_system.get_total_loot())
	#disable spawn
	remove_child(spawner)
	#clean queue
	merge_system.drop_queue()
	#disable merge
	animation_transition.play("fade_out")

# Load looted scene
func _change_looted_scene():
	get_tree().change_scene_to_file(next_scene.resource_path)

# Called by merge system. raises progress
func _on_merge_system_loot_dropped(_v):
	progress_bar.value += _v
	if progress_bar.value == 100:
		_transition_to_shop()
