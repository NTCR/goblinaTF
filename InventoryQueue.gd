extends Panel
 
@onready var slots = get_children()
var artifacts = {}
 
func _ready():
	for slot in slots:
		artifacts[slot.name] = null

#not how im going to use it. this was equipment slot 
#func insert_item(item):
#	var item_pos = item.rect_global_position + item.rect_size / 2
#	var slot = get_slot_under_pos(item_pos)
#	if slot == null:
#		return false
#
#	var item_slot = ArtifactDB.get_artifact(item.get_meta("id"))["slot"]
#	if item_slot != slot.name:
#		return false
#	if items[item_slot] != null:
#		return false
#	items[item_slot] = item
#	item.rect_global_position = slot.rect_global_position + slot.rect_size / 2 - item.rect_size / 2
#	return true
 
func grab_artifact(pos):
	var artifact = get_artifact_under_pos(pos)
	if artifact == null:
		return null
 
	var queue_slot = ArtifactDB.get_artifact(artifact.get_meta("id"))["slot"]
	artifacts[queue_slot] = null
	return artifact
 
func get_slot_under_pos(pos):
	return get_thing_under_pos(slots, pos)
 
func get_artifact_under_pos(pos):
	return get_thing_under_pos(artifacts.values(), pos)
#check if pos is in arr element 
func get_thing_under_pos(arr, pos):
	for thing in arr:
		if thing != null and thing.get_global_rect().has_point(pos):
			return thing
	return null
