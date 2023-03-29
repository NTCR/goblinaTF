extends Control

#ref to each member
@onready var inv_base = $InventoryBase
@onready var grid_bkpk = $GridBackPack
@onready var inv_queue = $InventoryQueue

#grab and release vars
var artifact_held = null
var artifact_offset = Vector2() #so the artifacts doesn't snap directly into the mouse. it keeps its relative position when grabed
var last_container = null
var last_pos = Vector2()

#called every frame: check if mouse in merge zone. enables grab and release
func _process(delta):
	var cursor_pos = get_global_mouse_position()
	if Input.is_action_just_pressed("inv_grab"):
		grab(cursor_pos)
	if Input.is_action_just_released("inv_grab"):
		release(cursor_pos)
	if artifact_held != null:
		artifact_held.global_position = cursor_pos + artifact_offset #artifact follows the mouse

#CHECK grab_item method -> method in containers (we expect grid and inv queue)
#grab functionality: 
func grab(cursor_pos):
	var c = get_container_under_cursor(cursor_pos)
	if c != null and c.has_method("grab_artifact"):
		artifact_held = c.grab_artifact(cursor_pos)
		if artifact_held != null: #update grab-release vars
			last_container = c
			last_pos = artifact_held.position
			artifact_offset = artifact_held.global_position - cursor_pos
			var old_parent = artifact_held.get_parent()
			old_parent.remove_child(artifact_held)
			add_child(artifact_held)

func release(cursor_pos):
	if artifact_held == null:
		return
	var c = get_container_under_cursor(cursor_pos)
	if c == null: #I want to return item to original position, but not if it was inventory
			return_item()
	elif c.has_method("insert_artifact"): #insert_artifact method-> method in containers
		if c.insert_artifact(artifact_held): #si hay espacio
			artifact_held = null
		else:
			return_item()
	else: #c is a container but with no method
		return_item()

#HELPERS
#ray function
func get_container_under_cursor(cursor_pos):
	var containers = [grid_bkpk, inv_queue, inv_base] #order matters. sets priority
	for c in containers:
		if c.get_global_rect().has_point(cursor_pos):
			return c
	return null

#debug purpose
func drop_item():
	artifact_held.queue_free() #deletes item
	artifact_held = null

func return_item(): #will revise code. child order etc.
	if last_container != grid_bkpk:
			drop_item()
	else:
		artifact_held.position = last_pos
		last_container.insert_artifact(artifact_held)
		remove_child(artifact_held)
		last_container.add_child(artifact_held)
		artifact_held = null


func _on_player_looted(loot_type):
	inv_queue.pickup_item(loot_type)
