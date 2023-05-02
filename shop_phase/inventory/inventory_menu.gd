extends Panel

@export_category("Components:")
@export var entries_container : BoxContainer

const INVENTORY_ENTRY = preload("res://shop_phase/inventory/inventory_entry.tscn")

func _ready():
	
	for _i in range(0,ArtifactDB.inventory_size()):
		var _artifact_id = ArtifactDB.inventory_get_at(_i)
		var _entry = INVENTORY_ENTRY.instantiate()
		var _artifact_info = ArtifactDB.ARTIFACTS[_artifact_id]
		_entry.set_artifact_image(_artifact_info["asset"])
		_entry.set_artifact_name(_artifact_info["name"])
		_entry.set_artifact_id(_artifact_id)
		entries_container.add_child(_entry)
