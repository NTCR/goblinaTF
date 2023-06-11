extends TextureRect

func setup_box(_a : Artifact):
	var _sprite = Sprite2D.new()
	_sprite.texture = load(_a.get_texture_path())
	_sprite.position = size/2
	var _desired_scale = size * 0.85 * 0.001
	_sprite.scale = _desired_scale
	add_child(_sprite)

func free_box():
	if get_child_count() > 0:
		get_child(0).queue_free()
