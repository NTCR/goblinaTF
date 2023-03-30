extends Node

const enemy = preload("res://baddie/enemy.tscn") 

func _on_merge_system_raise_progress(v):
	$ProgressBar.value += v
	if $ProgressBar.value == 100:
		transition_to_runner()
#revisable: por decidir si runner
func transition_to_runner():
	#disable spawn
	remove_child($Spawner)
	#clean queue
	$MergeSystem.drop_queue()
	#disable merge
	$TransitionMerge.play("fade_out")
