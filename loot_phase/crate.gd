extends TextureRect

signal looted(info_loot,info_offset)
const TYPES = [Vector2(2,2), Vector2(1,3), Vector2(3,1)]
var loot : Loot

func _ready():
	var _rand_type = randi_range(0,2)
	loot = Loot.new(TYPES[_rand_type], 1)

func _gui_input(_event):
	if _event is InputEventMouseButton and _event.button_index == MOUSE_BUTTON_LEFT:
		if _event.pressed:
			var _drag_instance = DragPreview.new()
			var _desired_size = Vector2(144*loot.size_cells[0], 144*loot.size_cells[1]) #HARDCODED
			var _mouse_offset = _desired_size/2
			_drag_instance.create_drag("res://loot_phase/loot/crate_common.png", _desired_size, _mouse_offset)
			get_tree().current_scene.add_child(_drag_instance)
			#mando señal
			emit_signal("looted",loot,_mouse_offset)
			#new loot DEBUG
			randomize()
			var _rand_type = randi_range(0,2)
			loot.swap_size(TYPES[_rand_type])

func _exit_tree():
	loot.free()
