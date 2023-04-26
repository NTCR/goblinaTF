extends Panel

signal card_try(charm_id)

@onready var card_texture = $TextureCurrentCard

var free_slot = true

func is_free():
	return free_slot
	
func assign_texture(card_asset):
	card_texture.texture = load(card_asset)
	free_slot = false
	
func make_free():
	card_texture.texture = null
	free_slot = true

func _can_drop_data(at_position, data):
	#data es un artefacto id
	if ArtifactDB.CHARMS.has(data) and free_slot:
		return true

func _drop_data(at_position, data):
	emit_signal("card_try",data)
