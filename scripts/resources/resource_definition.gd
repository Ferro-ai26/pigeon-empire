class_name ResourceDefinition
extends RefCounted

var _semantic_id: String
var _display_name: String
var _short_description: String
var _icon_slot: String
var _style_slot: String


func _init(
	semantic_id: String,
	display_name: String,
	short_description: String,
	icon_slot: String,
	style_slot: String
) -> void:
	_semantic_id = semantic_id
	_display_name = display_name
	_short_description = short_description
	_icon_slot = icon_slot
	_style_slot = style_slot


func get_semantic_id() -> String:
	return _semantic_id


func get_display_name() -> String:
	return _display_name


func get_short_description() -> String:
	return _short_description


func get_icon_slot() -> String:
	return _icon_slot


func get_style_slot() -> String:
	return _style_slot
