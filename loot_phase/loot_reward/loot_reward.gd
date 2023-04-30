extends PanelContainer

@export var member_count : Label
@export var member_texture : TextureRect

func apply_texture(_texture_path):
	member_texture.texture = load(_texture_path)
	
func apply_count(_count):
	member_count.text = "x" + str(_count)
