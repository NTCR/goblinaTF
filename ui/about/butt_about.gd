extends TextureButton

const ABOUT_PANEL = preload("res://ui/about/panel_about.tscn")

var _is_open = false

func _on_pressed():
	if not _is_open:
		var _panel = ABOUT_PANEL.instantiate()
		_panel.position = Vector2(544,382)
		_panel.connect("panel_closed",Callable(self,"_closed"))
		get_tree().current_scene.add_child(_panel)
		_panel.size = Vector2(643, 643)
		_is_open = true

func _closed():
	_is_open = false
