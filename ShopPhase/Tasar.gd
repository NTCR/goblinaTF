extends Control

const entry_base = preload("res://ShopPhase/Submenus/LibroEntry.tscn")

var curr_artifact
var curr_reveal
var charms_revealed = {} #during this session
#key is artifact id, value is array with chamrs revealed this session

func current_menu():
	self.visible=true

func leave_menu():
	self.visible=false
	return true

#arrastrar un artefacto inicia el tasar
func _on_drop_panel_begin_phase(artifact_id):
	#check if item is completed or valid
	$TasarPanel.visible = true
	$DropPanel.visible = false
	curr_artifact = artifact_id
	curr_reveal = _charm_validreveal()
	if curr_reveal == null:
		$TasarPanel/Completado.visible = true
		$TasarPanel/Completado/ContenedorLibroEntry.add_child(_load_bookentry(artifact_id))
	else:
		$TasarPanel/Valid.visible = true
		#load book entry
		$TasarPanel/Valid/ContenedorLibroEntry.add_child(_load_bookentry(artifact_id))
		var arbitrary_price = _calculate_price()
		$TasarPanel/Valid/TextPrice.text = "Tasar este artefacto te costara " + str(arbitrary_price) + " gold"

func _on_butt_completed_up():
	$TasarPanel/Completado/ContenedorLibroEntry.get_child(0).queue_free()
	_restore_initial_state()

func _on_butt_tasar_up():
	if ArtifactDB.curr_gold < _calculate_price():
		_restore_initial_state()
		return
	$TasarPanel/Valid/ContenedorLibroEntry.get_child(0).queue_free()
	$TasarPanel/Valid.visible = false
	$TasarPanel/Reveal.visible = true
	#mostrar encanto + recordar encanto mostrado
	$TasarPanel/Reveal/CardIcon.texture = load(ArtifactDB.get_cardicon(curr_reveal))
	if charms_revealed.has(curr_artifact):
		charms_revealed[curr_artifact].append(curr_reveal)
	else:
		charms_revealed[curr_artifact] = [curr_reveal]
	
func _on_butt_reveal_up():
	_restore_initial_state()

func _restore_initial_state():
	$DropPanel.visible = true
	$TasarPanel.visible = false
	$TasarPanel/Completado.visible = false
	$TasarPanel/Valid.visible = false
	$TasarPanel/Reveal.visible = false
	curr_artifact = null
	curr_reveal = null


func _charm_validreveal():
	var artifact_charms = ArtifactDB.ARTIFACTS[curr_artifact]["charm"]
	var previous_matters = curr_artifact in charms_revealed.keys()
	for _charm in artifact_charms:
		if previous_matters:
			if !ArtifactDB.is_artifactcharmdiscovered(curr_artifact,_charm) and _charm not in charms_revealed[curr_artifact]:
				return _charm
		else:
			if !ArtifactDB.is_artifactcharmdiscovered(curr_artifact,_charm):
				return _charm
	return null

func _load_bookentry(artifact_id):
	var entry = entry_base.instantiate()
	var artifact_info = ArtifactDB.ARTIFACTS[artifact_id]
	entry.set_artifactimage(artifact_info["asset"])
	entry.set_artifactname(artifact_info["name"])
	entry.set_artifactdesc(artifact_info["desc"])
	var icon_paths = []
	for charm_id in artifact_info["charm"]:
		if ArtifactDB.is_artifactcharmdiscovered(artifact_id,charm_id):
			icon_paths.append(ArtifactDB.get_cardicon(charm_id))
		else:
			icon_paths.append(ArtifactDB.get_cardicon(""))
	entry.set_artifactcharms(icon_paths)
	return entry
	
func _calculate_price():
	return 200
