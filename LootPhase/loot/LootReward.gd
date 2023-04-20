extends PanelContainer

@export var member_count : Label
@export var member_texture : TextureRect

func apply_texture(texture_path):
	member_texture.texture = load(texture_path)
	
func apply_count(count):
	member_count.text = "x" + str(count)
