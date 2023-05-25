extends Sprite2D

@export_category("Configuration:")
@export var crate_type : Loot.LOOT_TYPES
@export var bag_reference : Bag
var _loot : Loot

func _ready():
	_loot = Loot.new(crate_type)

func _input(_event):
	if _event is InputEventMouseButton and _event.button_index == MOUSE_BUTTON_LEFT:
		if get_rect().has_point(to_local(_event.position)) and _event.pressed:
			#crate por ahora: pulso, genera drag loot y permite soltarlo en bag
			#crea lootbag
			var _drag_instance = LootDrag.new()
			var _size = Bag.CELL_SIZE * _loot.get_size()
			var _mouse_offset = _size/2
			_drag_instance.configure_loot_drag(bag_reference, _loot, _size, _mouse_offset)
			get_tree().current_scene.add_child(_drag_instance)

func _exit_tree():
	_loot.free()
