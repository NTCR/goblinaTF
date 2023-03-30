extends Panel

const artifact_base = preload("res://merge_system/ArtifactBase.tscn") 
const artifact_types = ["sword", "armor", "potato"]

#func _process(delta):
#	if Input.is_action_just_pressed("spawn_artifact"):
#		pickup_item(artifact_types[randi() % 3])

func pickup_item(artifact_type):
	var artifact = artifact_base.instantiate()
	artifact.set_meta("type", artifact_type)
	artifact.set_meta("tier",1)
	artifact.texture = load(ArtifactDB.get_artifact(artifact_type)[1]) #metadata del item es un dictionary
	var availableSlot = get_available_slot()
	if availableSlot == null:
		print("queue is full!")
		return
	availableSlot.add_child(artifact)
 
func grab_artifact(pos):
	var slot = get_slot_under_pos(pos)
	var artifact = slot.get_child(0)
	if artifact == null:
		return null
	return artifact
 
func get_slot_under_pos(pos):
	for slot in get_children():
		if slot != null and slot.get_global_rect().has_point(pos):
			return slot
	return null

func get_available_slot():
	for slot in get_children():
		if slot.get_child_count() == 0:
			return slot
	return null
	
func empty_queue():
	for slot in get_children():
		if slot.get_child_count() > 0:
			var artf = slot.get_child(0)
			artf.queue_free()
