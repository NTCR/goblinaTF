extends Panel

@export var entries_node : BoxContainer

const entry_base = preload("res://ShopPhase/Submenus/InventoryEntry.tscn")

func _ready():
	for artifact_id in ArtifactDB.inventory:
		var entry = entry_base.instantiate()
		var artifact_info = ArtifactDB.ARTIFACTS[artifact_id]
		entry.set_artifactimage(artifact_info["asset"])
		entry.set_artifactname(artifact_info["name"])
		entry.set_artifactid(artifact_id)
		entries_node.add_child(entry)
