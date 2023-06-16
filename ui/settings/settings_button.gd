extends TextureButton

signal settings_closed()

const SETTINGS_PANEL = preload("res://ui/settings/settings_panel.tscn")

func _on_pressed():
	var _panel = SETTINGS_PANEL.instantiate()
	_panel.find_child("Control").connect("panel_closed",Callable(self,"_closed"))
	get_tree().current_scene.add_child(_panel)

func _closed():
	settings_closed.emit()
