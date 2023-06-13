extends TextureButton

const INVENTORY_PANEL = preload("res://shop_phase/inventario_vertical/inventory_panel.tscn")

var _is_open = false

func _on_pressed():
	if not _is_open:
		var _panel = INVENTORY_PANEL.instantiate()
		_panel.position = Vector2(64,64)
		_panel.connect("panel_closed",Callable(self,"_closed"))
		get_tree().current_scene.find_child("UI").add_child(_panel)
		_is_open = true

func _closed():
	_is_open = false
