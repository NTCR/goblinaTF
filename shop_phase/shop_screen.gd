extends Control

const BOOK_MENU = preload("res://shop_phase/book/book_menu.tscn")
const INV_MENU = preload("res://shop_phase/inventory/inventory_menu.tscn")
@export_category("Buttons:")
@export var butt_revelar  : Button
@export var butt_comercio : Button
@export var butt_tasar  : Button
@export var butt_volver : Button
@export var butt_door : TextureButton
@export_category("Components:")
@export var text_state : Label
@export var revelar_menu : Control
@export var comercio_menu : Control
@export var tasar_menu : Control
@export_category("Next scene:")
@export_file var loot_scene 
@export_file var end_scene
var libro_submenu
var inv_submenu
var curr_menu

func _process(_Delta):
	text_state.text = "CURRENT GOLD:\n" + str(ArtifactDB.gold_total())

# BUTTONS
func _on_butt_libro_button_up():
	if inv_submenu:
		return
	if libro_submenu == null:
		_show_libro()
	else:
		_hide_libro()

func _on_butt_inv_button_up():
	if libro_submenu:
		return
	if inv_submenu == null:
		_show_inv()
	else:
		_hide_inv()

func _on_butt_revelar_button_up():
	_hide_bottui()
	revelar_menu.current_menu()
	curr_menu = revelar_menu
	
func _on_butt_comercio_button_up():
	_hide_bottui()
	comercio_menu.current_menu()
	curr_menu = comercio_menu

func _on_butt_tasar_button_up():
	_hide_bottui()
	tasar_menu.current_menu()
	curr_menu = tasar_menu


func _on_butt_volver_button_up():
	if curr_menu.leave_menu():
		_show_bottui()
		curr_menu = null

# TOGGLE VISIBILITY
func _hide_bottui():
	butt_revelar.visible = false
	butt_comercio.visible = false
	butt_tasar.visible = false
	butt_volver.visible = true
	butt_door.visible = false

func _show_bottui():
	butt_revelar.visible = true
	butt_comercio.visible = true
	butt_tasar.visible = true
	butt_volver.visible = false
	butt_door.visible = true

func _hide_inv():
	inv_submenu.queue_free()
	inv_submenu = null
	
func _hide_libro():
	libro_submenu.queue_free()
	libro_submenu = null

func _show_inv():
	inv_submenu = INV_MENU.instantiate()
	add_child(inv_submenu)

func _show_libro():
	libro_submenu = BOOK_MENU.instantiate()
	add_child(libro_submenu)

#LOOT SCENE
func _on_butt_door_up():
	get_tree().change_scene_to_file(loot_scene)

# END GAME
func _on_comercio_game_over():
	get_tree().change_scene_to_file(end_scene)
