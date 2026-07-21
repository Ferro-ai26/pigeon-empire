class_name GatheringActionDefinition
extends RefCounted

var _action_id: String
var _resource_id: String
var _reward_amount: int
var _display_name: String
var _short_description: String
var _icon_slot: String
var _style_slot: String


func _init(
	action_id: String,
	resource_id: String,
	reward_amount: int,
	display_name: String,
	short_description: String,
	icon_slot: String,
	style_slot: String
) -> void:
	_action_id = action_id
	_resource_id = resource_id
	_reward_amount = reward_amount
	_display_name = display_name
	_short_description = short_description
	_icon_slot = icon_slot
	_style_slot = style_slot


func get_action_id() -> String:
	return _action_id


func get_resource_id() -> String:
	return _resource_id


func get_reward_amount() -> int:
	return _reward_amount


func get_display_name() -> String:
	return _display_name


func get_short_description() -> String:
	return _short_description


func get_icon_slot() -> String:
	return _icon_slot


func get_style_slot() -> String:
	return _style_slot
