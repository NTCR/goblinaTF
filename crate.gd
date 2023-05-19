extends TextureRect

signal looted(info_loot,info_offset)
const DRAG_PREVIEW = preload("res://shop_phase/drag_and_drop/drag_preview.tscn")
const TYPES = [Vector2(2,2), Vector2(1,3), Vector2(3,1)]
var loot : Loot

func _ready():
	var _rand_type = randi_range(0,2)
	loot = Loot.new(TYPES[_rand_type], 1)

func _gui_input(_event):
	if _event is InputEventMouseButton and _event.button_index == MOUSE_BUTTON_LEFT:
		if _event.pressed:
			#genero drag
			var _drag_instance = DRAG_PREVIEW.instantiate()
			_drag_instance.texture = load("res://loot_phase/loot/crate_common.png")
			var _desired_size = Vector2(144*loot.size_cells[0], 144*loot.size_cells[1]) #HARDCODED
			_drag_instance.scale = _desired_size/_drag_instance.texture.get_size()
			get_tree().current_scene.add_child(_drag_instance)
			#mando señal
			var _mouse_offset = _desired_size/2
			emit_signal("looted",loot,_mouse_offset)
			#new loot DEBUG
			randomize()
			var _rand_type = randi_range(0,2)
			loot.swap_size(TYPES[_rand_type])

func _exit_tree():
	loot.free()
