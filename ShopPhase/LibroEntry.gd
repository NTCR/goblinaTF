extends HBoxContainer

@export var artifact_image : TextureRect
@export var artifact_name : Label
@export var artifact_desc : Label
@export var artifact_charm : Label

func set_artifactimage(image_path):
	artifact_image.texture = load(image_path)
	
func set_artifactname(_name):
	artifact_name.text = _name
	
func set_artifactdesc(_desc):
	artifact_desc.text = _desc
	
func set_artifactcharm(_charm):
	artifact_charm.text = _charm

func set_artifactcharms(array_paths):
	var artifact_charms = $GridContainer.get_children()
	for i in range(0,array_paths.size()):
		artifact_charms[i].texture = load(array_paths[i])
