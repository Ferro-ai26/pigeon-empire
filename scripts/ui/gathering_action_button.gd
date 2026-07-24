class_name GatheringActionButton
extends Button

var _action_id: String = ""
var _icon_slot: String = ""
var _style_slot: String = ""


func bind_definition(definition: GatheringActionDefinition) -> bool:
	if definition == null or definition.get_action_id().is_empty():
		return false
	_action_id = definition.get_action_id()
	_icon_slot = definition.get_icon_slot()
	_style_slot = definition.get_style_slot()
	text = definition.get_display_name()
	tooltip_text = definition.get_short_description()
	return true


func get_action_id() -> String:
	return _action_id


func get_icon_slot() -> String:
	return _icon_slot


func get_style_slot() -> String:
	return _style_slot
