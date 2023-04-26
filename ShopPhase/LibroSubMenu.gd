extends Panel

@export var entries_node : BoxContainer

const entry_base = preload("res://ShopPhase/LibroEntry.tscn")

func _ready():
	var all_artifactsid = ArtifactDB.ARTIFACTS.keys()
	for artifact_id in all_artifactsid:
		var entry = entry_base.instantiate()
		var artifact_info = ArtifactDB.ARTIFACTS[artifact_id]
		entry.set_artifactimage(artifact_info["asset"])
		entry.set_artifactname(artifact_info["name"])
		entry.set_artifactdesc(artifact_info["desc"])
		var icon_paths = []
		for charm in artifact_info["charm"]:
			icon_paths.append(ArtifactDB.get_cardicon(charm))
		entry.set_artifactcharms(icon_paths)
		entry.set_meta("type", artifact_info["type"])
		entries_node.add_child(entry)


func _on_butt_all_button_up():
	for entry in entries_node.get_children():
		entry.visible = true


func _on_butt_swords_button_up():
	for entry in entries_node.get_children():
		if entry.get_meta("type") == ArtifactDB.TYPES[0]:
			entry.visible = true
		else:
			entry.visible = false


func _on_butt_armors_button_up():
	for entry in entries_node.get_children():
		if entry.get_meta("type") == ArtifactDB.TYPES[1]:
			entry.visible = true
		else:
			entry.visible = false


func _on_butt_potatos_button_up():
	for entry in entries_node.get_children():
		if entry.get_meta("type") == ArtifactDB.TYPES[2]:
			entry.visible = true
		else:
			entry.visible = false


func _on_button_button_up():
	queue_free()
