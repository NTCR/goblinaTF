extends Control

const BOOK_ENTRY = preload("res://shop_phase/book/book_entry.tscn")
@export_category("Components:")
@export var panel_tasar : Panel
@export var panel_drop_artifact : Panel
@export var context_complete : Control
@export var container_book_entry_complete : PanelContainer
@export var context_valid : Control
@export var container_book_entry_valid : PanelContainer
@export var text_valid : Label
@export var context_reveal : Control
@export var icon_reveal : TextureRect
var _curr_artifact
var _curr_reveal
var _charms_revealed = {} #during this session
#key is artifact id, value is array with chamrs revealed this session

func current_menu():
	visible=true

func leave_menu():
	visible=false
	return true

#arrastrar un artefacto inicia el tasar
func _on_drop_panel_begin_phase(_artifact_id):
	#check if item is completed or valid
	panel_tasar.visible = true
	panel_drop_artifact.visible = false
	_curr_artifact = _artifact_id
	_curr_reveal = _charm_valid_reveal()
	if _curr_reveal == null:
		context_complete.visible = true
		container_book_entry_complete.add_child(_load_book_entry(_artifact_id))
	else:
		context_valid.visible = true
		#load book entry
		container_book_entry_valid.add_child(_load_book_entry(_artifact_id))
		var _arbitrary_price = _calculate_price()
		text_valid.text = "Tasar este artefacto te costara " + \
				str(_arbitrary_price) + " gold"

func _charm_valid_reveal():
	var _artifact_charms = ArtifactDB.ARTIFACTS[_curr_artifact]["charm"]
	#podria primero usar complete, y luego las condiciones especificas de esta clase
	for _charm_code in _artifact_charms:
		var _charm_id = ArtifactDB.CHARMS.keys()[_charm_code]
		if not ArtifactDB.is_artifact_charm_discovered(_curr_artifact,_charm_id):
			if not(
					_curr_artifact in _charms_revealed.keys() and
					_charm_id in _charms_revealed[_curr_artifact]
			):
					return _charm_id
	return null

func _load_book_entry(_artifact_id):
	var _entry = BOOK_ENTRY.instantiate()
	var _artifact_info = ArtifactDB.ARTIFACTS[_artifact_id]
	_entry.set_artifact_image(_artifact_info["asset"])
	_entry.set_artifact_name(_artifact_info["name"])
	_entry.set_artifact_desc(_artifact_info["desc"])
	var _icon_paths = []
	for _charm_code in _artifact_info["charm"]:
		var _charm_id = ArtifactDB.CHARMS.keys()[_charm_code]
		if ArtifactDB.is_artifact_charm_discovered(_artifact_id,_charm_id):
			_icon_paths.append(ArtifactDB.get_card_icon(_charm_id))
		else:
			_icon_paths.append(ArtifactDB.get_card_icon(""))
	_entry.set_artifact_charm_icons(_icon_paths)
	if ArtifactDB.is_artifact_complete(_artifact_id):
		_entry.set_artifact_charm_text(_artifact_info["unlocked"])
	return _entry
#states through buttons
func _on_butt_completed_up():
	container_book_entry_complete.get_child(0).queue_free()
	_restore_initial_state()

func _on_butt_tasar_up():
	if ArtifactDB.gold_total() < _calculate_price(): #hardcoded not enough gold
		_restore_initial_state()
		return
	ArtifactDB.gold_spend(_calculate_price())
	container_book_entry_valid.get_child(0).queue_free()
	context_valid.visible = false
	context_reveal.visible = true
	#mostrar encanto + recordar encanto mostrado
	icon_reveal.texture = load(ArtifactDB.get_card_icon(_curr_reveal))
	if _charms_revealed.has(_curr_artifact):
		_charms_revealed[_curr_artifact].append(_curr_reveal)
	else:
		_charms_revealed[_curr_artifact] = [_curr_reveal]
	
func _on_butt_reveal_up():
	_restore_initial_state()

func _restore_initial_state():
	panel_drop_artifact.visible = true
	panel_tasar.visible = false
	context_complete.visible = false
	context_valid.visible = false
	context_reveal.visible = false
	_curr_artifact = null
	_curr_reveal = null

func _calculate_price():
	return 200
