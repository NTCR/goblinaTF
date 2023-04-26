extends Node

@export var nextScene : PackedScene

#called by merge system. raises progress
func _on_merge_system_raise_progress(v):
	$ProgressBar.value += v
	if $ProgressBar.value == 100:
		transition_to_shop()

#takes steps towards shop scene
func transition_to_shop():
	#store loot
	LootDB.save_loot($MergeSystem.get_total_loot())
	#disable spawn
	remove_child($Spawner)
	#clean queue
	$MergeSystem.drop_queue()
	#disable merge
	$TransitionMerge.play("fade_out")

func change_lootedScene():
	get_tree().change_scene_to_file(nextScene.resource_path)
