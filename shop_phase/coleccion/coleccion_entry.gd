extends Control

@export_category("Components:")
@export var artifact_box : TextureRect
@export var name_label : Label
@export var charm_container : HBoxContainer
@export var desc_label : Label
@export var ench_label : Label

func setup_entry(_a : Artifact):
	if _a != null:
		artifact_box.setup_box(_a)
		name_label.text = _a.name
		var _color = LootBag.TIER_COLORS[_a.rarity+1]
		name_label.add_theme_color_override("font_color",_color)
		for _charm in _a.charms_complete:
			var _texture_path : String
			if Database.progress_has_charm_succeeded(_a, _charm):
				_texture_path = Charm.get_icon_normal(_charm)
			else:
				_texture_path = Charm.UNDISCOVERED_CHARM
			var _texture_rect = TextureRect.new()
			_texture_rect.texture = load(_texture_path)
			_texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			var _desired_size = Vector2(55,55)
			_texture_rect.set_custom_minimum_size(_desired_size)
			charm_container.add_child(_texture_rect)
		desc_label.text = _a.description
		if Database.progress_is_artifact_completed(_a):
			ench_label.text = _a.enchant
	
