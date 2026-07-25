class_name BuildingDefinition
extends RefCounted

var _semantic_id: String
var _footprint_width: int
var _footprint_height: int
var _construction_costs: Dictionary
var _storage_contributions: Dictionary
var _display_name: String
var _description: String
var _icon_slot: String
var _style_slot: String
var _world_visual_slot: String


func _init(
	semantic_id: String,
	footprint_width: int,
	footprint_height: int,
	construction_costs: Dictionary,
	storage_contributions: Dictionary,
	display_name: String,
	description: String,
	icon_slot: String,
	style_slot: String,
	world_visual_slot: String
) -> void:
	_semantic_id = semantic_id
	_footprint_width = footprint_width
	_footprint_height = footprint_height
	_construction_costs = construction_costs.duplicate(true)
	_storage_contributions = storage_contributions.duplicate(true)
	_display_name = display_name
	_description = description
	_icon_slot = icon_slot
	_style_slot = style_slot
	_world_visual_slot = world_visual_slot


func get_semantic_id() -> String:
	return _semantic_id


func get_footprint_width() -> int:
	return _footprint_width


func get_footprint_height() -> int:
	return _footprint_height


func get_construction_costs() -> Dictionary:
	return _construction_costs.duplicate(true)


func get_storage_contributions() -> Dictionary:
	return _storage_contributions.duplicate(true)


func get_display_name() -> String:
	return _display_name


func get_description() -> String:
	return _description


func get_icon_slot() -> String:
	return _icon_slot


func get_style_slot() -> String:
	return _style_slot


func get_world_visual_slot() -> String:
	return _world_visual_slot
