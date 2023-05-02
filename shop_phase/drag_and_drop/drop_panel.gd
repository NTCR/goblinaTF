extends Panel

signal artifact_dropped(artifact_id)

func _can_drop_data(_at_position, _data):
	#data es un artefacto id
	if ArtifactDB.ARTIFACTS.has(_data):
		return true

func _drop_data(_at_position, _data):
	emit_signal("artifact_dropped",_data)
