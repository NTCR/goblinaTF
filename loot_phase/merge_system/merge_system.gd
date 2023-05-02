extends Control

const DESTROY_EFFECT = preload("res://loot_phase/merge_system/destroyed_particle.tscn")

signal loot_dropped(v)

@export_category("Components:")
@export var inv_base : Panel
@export var inv_queue : Panel
@export var grid_bkpk : TextureRect


@export_category("Gameplay values:")
#how much progress bar increases per artifact dropped
@export_range(0,100) var points_per_artifact = 20 

#grab and release control vars
var _artifact_held = null
var _artifact_offset = Vector2() #so the artifacts doesn't snap directly into the mouse. it keeps its relative position when grabed
var _last_container = null #so we can return the artifact to its original container
var _last_pos = Vector2()

# Check if mouse in merge zone. Enables grab and release
func _process(_delta):
	var _cursor_pos = get_global_mouse_position()
	if Input.is_action_just_pressed("left_mouse"):
		_grab(_cursor_pos)
	if Input.is_action_just_released("left_mouse"):
		_release(_cursor_pos)
	if _artifact_held != null:
		_artifact_held.global_position = _cursor_pos + _artifact_offset #artifact follows the mouse

# Returns a loot structure
func store_loot():
	var _arr_items = grid_bkpk.get_children()
	for _item in _arr_items:
		var _type = _item.get_meta("type")
		var _tier = _item.get_meta("tier")
		LootDB.add_to_loot(_type,_tier)

# Called to drop queue TEMPORAL
func drop_queue():
	#clean queue
	inv_queue.empty_queue()
	#spawn destroy particles
	for slot in inv_queue.get_children():
		var tParticle = DESTROY_EFFECT.instantiate()
		add_child(tParticle)
		tParticle.global_position = slot.global_position
		tParticle.emitting = true

# Grab loot
func _grab(_cursor_pos):
	var c = _get_container_under_cursor(_cursor_pos)
	if c != null and c.has_method("grab_artifact"):
		_artifact_held = c.grab_artifact(_cursor_pos)
		if _artifact_held != null: #update grab-release vars
			_last_container = c
			_last_pos = _artifact_held.position
			_artifact_offset = _artifact_held.global_position - _cursor_pos
			#reorder scene tree
			var _old_parent = _artifact_held.get_parent()
			_old_parent.remove_child(_artifact_held)
			add_child(_artifact_held)

# Release loot (or drop)
func _release(_cursor_pos):
	if _artifact_held == null:
		return
	var c = _get_container_under_cursor(_cursor_pos)
	if c == null: #artifact released outside any container
		_return_item()
	elif c.has_method("insert_artifact"): #release in a container with insert_artifact method
		if c.insert_artifact(_artifact_held): #valid operation
			_artifact_held = null
		else:
			_return_item()
	else: #c is a container but with no such method
		_return_item()

# Signal received from player. Generates loot bag in queue
func _on_player_looted(_loot_type):
	if inv_queue.get_available_slot() != null:
		inv_queue.pickup_item(_loot_type)
	else:
		_item_destroyed(Vector2(718,358)) #hard coded because only for prototype purposes

#LOOT STATE AFTER RELEASE
func _return_item(): #will revise code. child order etc.
	if _last_container != grid_bkpk:
			_drop_item()
	else:
		_artifact_held.position = _last_pos
		_last_container.insert_artifact(_artifact_held)
		remove_child(_artifact_held)
		_last_container.add_child(_artifact_held)
		_artifact_held = null

func _drop_item():
	_artifact_held.queue_free() #deletes item
	_artifact_held = null
	_item_destroyed(get_global_mouse_position())
#HELPERS
#ray function
func _get_container_under_cursor(_cursor_pos):
	var containers = [grid_bkpk, inv_queue, inv_base] #order matters. sets priority
	for c in containers:
		if c.get_global_rect().has_point(_cursor_pos):
			return c
	return null
#destroy effect
func _item_destroyed(_pos):
	var tParticle = DESTROY_EFFECT.instantiate()
	add_child(tParticle)
	tParticle.global_position = _pos
	tParticle.emitting = true
	emit_signal("loot_dropped",points_per_artifact)

