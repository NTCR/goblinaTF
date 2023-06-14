extends TextureButton
class_name CharmSlot

signal charm_selected(slot)

var _empty := true
var _locked := false
var _charm : Charm.CHARMS

func get_charm() -> Charm.CHARMS:
	return _charm

func butt_setup(_c : Charm.CHARMS):
	texture_normal = load(Charm.get_icon_normal(_c))
	texture_hover = load(Charm.get_icon_hover(_c))
	texture_pressed = load(Charm.get_icon_click(_c))
	_charm = _c
	_empty = false

func slot_setup():
	slot_empty()

func butt_preference():
	self_modulate = Color(1,1,1,1)
	pass

func butt_undiscovered():
	self_modulate = Color(1,1,1,0.8)
	pass

func butt_invalid():
	self_modulate = Color(1,1,1,0.3)
	disabled = true
	pass

func slot_fill(_c : Charm.CHARMS):
	texture_normal = load(Charm.get_icon_normal(_c))
	texture_hover = load(Charm.get_icon_hover(_c))
	texture_pressed = load(Charm.get_icon_click(_c))
	_charm = _c
	_empty = false

func slot_empty():
	texture_normal = load(Charm.EMPTY_CHARM)
	texture_hover = null
	texture_pressed = null
	_empty = true

func slot_lock():
	_locked = true

func slot_is_empty() -> bool:
	return _empty

func _on_pressed():
	if not _empty and not _locked:
		charm_selected.emit(self)
