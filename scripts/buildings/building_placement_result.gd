class_name BuildingPlacementResult
extends RefCounted

const STATUS_VALID: StringName = &"valid"
const STATUS_INVALID_DEFINITION: StringName = &"invalid_definition"
const STATUS_INVALID_GRID_BOUNDS: StringName = &"invalid_grid_bounds"
const STATUS_OUT_OF_BOUNDS: StringName = &"out_of_bounds"
const STATUS_OCCUPIED_CONFLICT: StringName = &"occupied_conflict"

var _status: StringName
var _anchor: Vector2i
var _footprint_cells: Array[Vector2i]


func _init(status: StringName, anchor: Vector2i, footprint_cells: Array[Vector2i]) -> void:
	_status = status
	_anchor = anchor
	_footprint_cells = footprint_cells.duplicate()


func get_status() -> StringName:
	return _status


func is_valid() -> bool:
	return _status == STATUS_VALID


func get_anchor() -> Vector2i:
	return _anchor


func get_footprint_cells() -> Array[Vector2i]:
	return _footprint_cells.duplicate()
