extends TextureButton

signal artifact_selected(artifact)

var _artifact : Artifact = null

func setup_box(_a : Artifact):
	var _sprite = Sprite2D.new()
	_sprite.texture = load(_a.get_texture_path())
	_sprite.position = size/2
	var _desired_scale = size * 0.85 * 0.001
	_sprite.scale = _desired_scale
	add_child(_sprite)
	_artifact = _a

func _on_pressed():
	artifact_selected.emit(_artifact)
	disabled = true
