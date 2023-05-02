extends Panel

@export_category("Components:")
@export var entries_container : BoxContainer

const BOOK_ENTRY = preload("res://shop_phase/book/book_entry.tscn")

func _ready():
	var _all_artifacts = ArtifactDB.ARTIFACTS.keys()
	for _artifact_id in _all_artifacts:
		var _entry = BOOK_ENTRY.instantiate()
		if ArtifactDB.is_artifact_discovered(_artifact_id):
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
		_entry.set_meta("type",ArtifactDB.ARTIFACTS[_artifact_id]["type"])
		entries_container.add_child(_entry)


func _on_butt_all_button_up():
	for _entry in entries_container.get_children():
		_entry.visible = true

func _on_butt_swords_button_up():
	for _entry in entries_container.get_children():
		if _entry.get_meta("type") == ArtifactDB.TYPES["SWORD"]:
			_entry.visible = true
		else:
			_entry.visible = false

func _on_butt_armors_button_up():
	for _entry in entries_container.get_children():
		if _entry.get_meta("type") == ArtifactDB.TYPES["ARMOR"]:
			_entry.visible = true
		else:
			_entry.visible = false

func _on_butt_potatos_button_up():
	for _entry in entries_container.get_children():
		if _entry.get_meta("type") == ArtifactDB.TYPES["POTATO"]:
			_entry.visible = true
		else:
			_entry.visible = false

func _on_button_button_up():
	queue_free()
