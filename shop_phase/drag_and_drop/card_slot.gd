extends Panel

signal card_tried(charm_id)

@export_category("Components:")
@export var card_texture : TextureRect

var _free_slot = true

func is_free():
	return _free_slot
	
func assign_texture(_texture_path):
	card_texture.texture = load(_texture_path)
	_free_slot = false
	
func make_free():
	card_texture.texture = null
	_free_slot = true

func _can_drop_data(_at_position, _data):
	#data es un artefacto id
	if ArtifactDB.CHARMS.has(_data) and _free_slot:
		return true

func _drop_data(_at_position, _data):
	emit_signal("card_tried",_data)
