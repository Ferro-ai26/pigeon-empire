class_name BuildingInstanceRecord
extends RefCounted

var _instance_id: int
var _building_id: String
var _anchor: Vector2i
var _footprint_cells: Array[Vector2i]


func _init(instance_id: int, building_id: String, anchor: Vector2i, footprint_cells: Array[Vector2i]) -> void:
	_instance_id = instance_id
	_building_id = building_id
	_anchor = anchor
	_footprint_cells = footprint_cells.duplicate()


func get_registry_instance_id() -> int:
	return _instance_id


func get_building_id() -> String:
	return _building_id


func get_anchor() -> Vector2i:
	return _anchor


func get_footprint_cells() -> Array[Vector2i]:
	return _footprint_cells.duplicate()
