extends Control

const DESTROY_EFFECT = preload("res://LootPhase/merge_system/DestroyParticles.tscn")

#ref to each member
@onready var inv_base = $InventoryBase
@onready var grid_bkpk = $GridBackPack
@onready var inv_queue = $InventoryQueue
#how much progress bar increases per artifact dropped
@export var points_per_artifact = 20

signal raise_progress(v)

#grab and release control vars
var artifact_held = null
var artifact_offset = Vector2() #so the artifacts doesn't snap directly into the mouse. it keeps its relative position when grabed
var last_container = null #so we can return the artifact to its original container
var last_pos = Vector2()

#called every frame: check if mouse in merge zone. enables grab and release
func _process(_delta):
	var cursor_pos = get_global_mouse_position()
	if Input.is_action_just_pressed("inv_grab"):
		grab(cursor_pos)
	if Input.is_action_just_released("inv_grab"):
		release(cursor_pos)
	if artifact_held != null:
		artifact_held.global_position = cursor_pos + artifact_offset #artifact follows the mouse

#grab artifact
func grab(cursor_pos):
	var c = get_container_under_cursor(cursor_pos)
	if c != null and c.has_method("grab_artifact"):
		artifact_held = c.grab_artifact(cursor_pos)
		if artifact_held != null: #update grab-release vars
			last_container = c
			last_pos = artifact_held.position
			artifact_offset = artifact_held.global_position - cursor_pos
			#reorder scene tree
			var old_parent = artifact_held.get_parent()
			old_parent.remove_child(artifact_held)
			add_child(artifact_held)

#realease artifact
func release(cursor_pos):
	if artifact_held == null:
		return
	var c = get_container_under_cursor(cursor_pos)
	if c == null: #artifact released outside any container
		return_item()
	elif c.has_method("insert_artifact"): #release in a container with insert_artifact method
		if c.insert_artifact(artifact_held): #valid operation
			artifact_held = null
		else:
			return_item()
	else: #c is a container but with no such method
		return_item()

#HELPERS
#ray function
func get_container_under_cursor(cursor_pos):
	var containers = [grid_bkpk, inv_queue, inv_base] #order matters. sets priority
	for c in containers:
		if c.get_global_rect().has_point(cursor_pos):
			return c
	return null

#throw artifact
func drop_item():
	artifact_held.queue_free() #deletes item
	artifact_held = null
	item_destroyed(get_global_mouse_position())

func return_item(): #will revise code. child order etc.
	if last_container != grid_bkpk:
			drop_item()
	else:
		artifact_held.position = last_pos
		last_container.insert_artifact(artifact_held)
		remove_child(artifact_held)
		last_container.add_child(artifact_held)
		artifact_held = null

func _on_player_looted(loot_type): #signal received from player
	if inv_queue.get_available_slot() != null:
		inv_queue.pickup_item(loot_type)
	else:
		item_destroyed(Vector2(718,358)) #hard coded because only for prototype purposes

func item_destroyed(pos):
	var tParticle = DESTROY_EFFECT.instantiate()
	add_child(tParticle)
	tParticle.global_position = pos
	tParticle.emitting = true
	emit_signal("raise_progress",points_per_artifact)
	
func get_total_loot():
	var arr_items = grid_bkpk.get_children()
	var output_dict = {}
	for item in arr_items:
		var _type = item.get_meta("type")
		var _tier = item.get_meta("tier")
		if output_dict.has(_type):
			if output_dict[_type].has(_tier):
				output_dict[item.get_meta("type")][item.get_meta("tier")] += 1
			else:
				output_dict[_type][_tier] = 1
		else:
			output_dict[_type] = {}
			output_dict[_type][_tier] = 1
	return output_dict
	
func drop_queue():
	#clean queue
	inv_queue.empty_queue()
	#spawn destroy particles
	for slot in inv_queue.get_children():
		var tParticle = DESTROY_EFFECT.instantiate()
		add_child(tParticle)
		tParticle.global_position = slot.global_position
		tParticle.emitting = true

