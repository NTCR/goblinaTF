extends Control

const book_asset = preload("res://ShopPhase/LibroSubMenu.tscn")
const inv_asset = preload("res://ShopPhase/InventorySubMenu.tscn")
@export var butt_revelar  : Button
@export var butt_comercio : Button
@export var butt_tasar  : Button
@export var butt_volver : Button

var libro_submenu
var inv_submenu
var curr_menu


func _on_butt_libro_button_up():
	if inv_submenu != null:
		return
	if libro_submenu == null:
		show_libro()
	else:
		hide_libro()


func _on_butt_inv_button_up():
	if libro_submenu != null:
		return
	if inv_submenu == null:
		show_inv()
	else:
		hide_inv()

func _on_butt_revelar_button_up():
	hide_bottui()
	$Revelar.current_menu()
	curr_menu = $Revelar
	
func _on_butt_comercio_button_up():
	hide_bottui()
	$Comercio.current_menu()
	curr_menu = $Comercio
	
func _on_butt_volver_button_up():
	if curr_menu.leave_menu():
		show_bottui()
		curr_menu = null

func hide_bottui():
	butt_revelar.visible = false
	butt_comercio.visible = false
	butt_tasar.visible = false
	butt_volver.visible = true

func show_bottui():
	butt_revelar.visible = true
	butt_comercio.visible = true
	butt_tasar.visible = true
	butt_volver.visible = false

func hide_inv():
	inv_submenu.queue_free()
	inv_submenu = null
	
func hide_libro():
	libro_submenu.queue_free()
	libro_submenu = null

func show_inv():
	inv_submenu = inv_asset.instantiate()
	add_child(inv_submenu)
	
func show_libro():
	libro_submenu = book_asset.instantiate()
	add_child(libro_submenu)
