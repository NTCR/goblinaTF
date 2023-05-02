extends Control

@export_category("Buttons:")
@export var butt_loot : TextureButton
@export_category("Components:")
@export var panel_ui : Panel
@export var text_total_loot : Label
@export var text_artifact_name : Label
@export var texture_loot_bag : TextureRect
@export var texture_artifact : TextureRect

func _ready():
	_update_lootcount()

func current_menu():
	visible=true

func leave_menu():
	visible=false
	return true

func _on_revelar_left_button_up():
	var _first_in_loot = LootDB.get_loot_first_element()
	if _first_in_loot == null:
		#no hay loot
		return
	var _loot_type = _first_in_loot[0]
	var _loot_tier = _first_in_loot[1]
	texture_loot_bag.texture = load(LootDB.get_loot_bag(_loot_type, _loot_tier))
	var _artifact_id = ArtifactDB.loot_table(_loot_type, _loot_tier)
	texture_artifact.texture = load(ArtifactDB.ARTIFACTS[_artifact_id]["asset"])
	text_artifact_name.text = ArtifactDB.ARTIFACTS[_artifact_id]["name"]
	_update_lootcount()
	_reveal_state()
	ArtifactDB.discover_artifact(_artifact_id)
	ArtifactDB.inventory_add_artifact(_artifact_id)

func _on_butt_continue_up():
	_initial_state()
	
func _initial_state():
	panel_ui.visible = false
	butt_loot.disabled = false
	
func _reveal_state():
	panel_ui.visible = true
	butt_loot.disabled = true
	
func _update_lootcount():
	text_total_loot.text = "x" + str(LootDB.get_loot_size())

