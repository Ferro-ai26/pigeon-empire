class_name BuildingConstructionResult
extends RefCounted

const STATUS_SUCCESS: StringName = &"success"
const STATUS_MISSING_DEPENDENCY: StringName = &"missing_dependency"
const STATUS_INVALID_BUILDING_ID: StringName = &"invalid_building_id"
const STATUS_INVALID_PLACEMENT: StringName = &"invalid_placement"
const STATUS_INSUFFICIENT_RESOURCES: StringName = &"insufficient_resources"
const STATUS_COST_TRANSACTION_REJECTED: StringName = &"cost_transaction_rejected"

var _status: StringName
var _building_id: String
var _anchor: Vector2i
var _footprint_cells: Array[Vector2i]


func _init(status: StringName, building_id: String, anchor: Vector2i, footprint_cells: Array[Vector2i]) -> void:
	_status = status
	_building_id = building_id
	_anchor = anchor
	_footprint_cells = footprint_cells.duplicate()


func get_status() -> StringName:
	return _status


func is_success() -> bool:
	return _status == STATUS_SUCCESS


func get_building_id() -> String:
	return _building_id


func get_anchor() -> Vector2i:
	return _anchor


func get_footprint_cells() -> Array[Vector2i]:
	return _footprint_cells.duplicate()
