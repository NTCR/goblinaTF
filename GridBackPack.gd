extends TextureRect

var artifacts = [] #list of artifact instances
 
var grid = {} 
var cell_size = 32 #every cell 32x32px
var grid_width = 0
var grid_height = 0
 
func _ready():
	var s = get_grid_size(self)
	grid_width = s.x
	grid_height = s.y
 
	for x in range(grid_width): #setup 2d array, for now is a 2d dictionary, or a linked hash table
		grid[x] = {}
		for y in range(grid_height):
			grid[x][y] = false
 
func insert_artifact(artifact):
#	if can_be_merged(artifact): #CHECK codigo 
#		var currentArtifact = get_artifact_under_pos(get_global_mouse_position())
#		artifact.queue_free()
#		currentArtifact.set_meta("tier", currentArtifact.get_meta("tier")+1)
#		item.texture = load(ArtifactDB.get_artifact(item_id)["icon"]) #metadata del item es un dictionary
		
	
	#var artifact_pos = artifact.global_position + Vector2(cell_size / 2, cell_size / 2) #makes interaction smoother
	var g_pos = pos_to_grid_coord(artifact.position) #grid coordinates
	var artifact_size = get_grid_size(artifact) #could be set up in meta data - ASSUMES EVERY OBJECTS is rect
	if is_grid_space_available(g_pos.x, g_pos.y, artifact_size.x, artifact_size.y): #esta vacio
		set_grid_space(g_pos.x, g_pos.y, artifact_size.x, artifact_size.y, true)
		artifact.position = Vector2(g_pos.x, g_pos.y) * cell_size
		artifacts.append(artifact) #saves INSTANCE of artifact
		if artifact.get_parent() != self:
			add_child(artifact)
		return true	
	else:
		return false
 
func grab_artifact(pos):
	var artifact = get_artifact_under_pos(pos)
	if artifact == null:
		return null
 
#	var artifact_pos = artifact.global_position + Vector2(cell_size / 2, cell_size / 2)
	var g_pos = pos_to_grid_coord(artifact.position)
	var artifact_size = get_grid_size(artifact)
	set_grid_space(g_pos.x, g_pos.y, artifact_size.x, artifact_size.y, false)
 
	artifacts.remove_at(artifacts.find(artifact))
	return artifact

#global pos to grid coord
func pos_to_grid_coord(pos):
	var results = Vector2i()
	results.x = int(pos.x / cell_size)
	results.y = int(pos.y / cell_size)
	return results

#could be calculated previously
func get_grid_size(item):
	var results = Vector2i()
	var s = item.get_texture().get_size()
	results.x = int(s.x / cell_size)
	results.y = int(s.y / cell_size)
	return results
	
#check if invalid grid coordinates or can not fit
func is_valid_coord(gridX, gridY, sizeX ,sizeY):
	if gridX < 0 or gridY < 0:
		return false
	if gridX + sizeX > grid_width or gridY + sizeY > grid_height:
		return false
	return true
	
func is_grid_space_available(x, y, w ,h): #CHECK
	if x < 0 or y < 0:
		return false
	if x + w > grid_width or y + h > grid_height:
		return false
	for i in range(x, x + w):
		for j in range(y, y + h):
			if grid[i][j]:
				return false
	return true
	
#func can_be_merged(artifact):
#	var currentArtifact = get_artifact_under_pos(get_global_mouse_position())
#	if currentArtifact == null:
#		return false
#	if currentArtifact.get_meta("id") == artifact.get_meta("id") \
#	&& currentArtifact.get_meta("tier") == artifact.get_meta("tier"):
#		return true
#	else:
#		return false
 
func set_grid_space(x, y, w, h, state):
	for i in range(x, x + w):
		for j in range(y, y + h):
			grid[i][j] = state
 
func get_artifact_under_pos(pos):
	for artifact in artifacts:
		if artifact.get_global_rect().has_point(pos):
			return artifact
	return null
 
func insert_item_at_first_available_spot(item): #different from final functionality
	for y in range(grid_height):
		for x in range(grid_width):
			if !grid[x][y]:
				item.position = Vector2(x,y) * cell_size
				if insert_artifact(item):
					return true
	return false
