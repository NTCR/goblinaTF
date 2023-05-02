extends HBoxContainer

@export_category("Components:")
@export var artifact_image : TextureRect
@export var artifact_name : Label
@export var artifact_desc : Label
@export var artifact_charm : Label
@export var charm_container : GridContainer

func set_artifact_image(_image_path):
	artifact_image.texture = load(_image_path)
	
func set_artifact_name(_name):
	artifact_name.text = _name
	
func set_artifact_desc(_desc):
	artifact_desc.text = _desc
	
func set_artifact_charm_text(_charm):
	artifact_charm.text = _charm

func set_artifact_charm_icons(_array_paths):
	var _artifact_charms = charm_container.get_children()
	for _i in range(0,_array_paths.size()):
		_artifact_charms[_i].texture = load(_array_paths[_i])
