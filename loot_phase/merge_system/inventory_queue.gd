extends Panel

const ARTIFACT_BASE = preload("res://loot_phase/merge_system/artifact_base.tscn") 

# Called to empty inventory queue
func empty_queue():
	for _slot in get_children():
		if _slot.get_child_count() > 0:
			var _artf = _slot.get_child(0)
			_artf.queue_free()

# Called by merge system. Adds loot to inventory
func pickup_item(_artifact_type):
	var _artifact = ARTIFACT_BASE.instantiate()
	_artifact.set_meta("type", _artifact_type)
	_artifact.set_meta("tier",1)
	_artifact.texture = load(LootDB.get_loot_bag(_artifact_type)[1]) #metadata del item es un dictionary
	var _availableSlot = get_available_slot() #already checkd if free slot
	_artifact.position = Vector2( (_availableSlot.size.x / 2) - (_artifact.texture.get_width()/2),
			(_availableSlot.size.y/2) - (_artifact.texture.get_height()/2) )
	_availableSlot.add_child(_artifact)
 
func grab_artifact(_pos):
	var _slot = _get_slot_under_pos(_pos)
	var _artifact = _slot.get_child(0)
	if _artifact == null:
		return null
	return _artifact

func get_available_slot():
	for _slot in get_children():
		if _slot.get_child_count() == 0:
			return _slot
	return null 

#private
func _get_slot_under_pos(_pos):
	for _slot in get_children():
		if (_slot != null) and _slot.get_global_rect().has_point(_pos):
			return _slot
	return null




