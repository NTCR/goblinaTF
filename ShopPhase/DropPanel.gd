extends Panel

signal begin_phase(artifact_id)

func _can_drop_data(_at_position, data):
	#data es un artefacto id
	if ArtifactDB.ARTIFACTS.has(data):
		return true

func _drop_data(_at_position, data):
	emit_signal("begin_phase",data)
