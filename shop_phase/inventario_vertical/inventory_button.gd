extends TextureButton

const INVENTORY_PANEL = preload("res://shop_phase/inventario_vertical/inventory_panel.tscn")

func _on_pressed():
	var _panel = INVENTORY_PANEL.instantiate()
	_panel.position = Vector2(64,64)
	get_tree().current_scene.find_child("UI").add_child(_panel)
