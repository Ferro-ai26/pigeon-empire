class_name BuildingRegistrationResult
extends RefCounted

const STATUS_SUCCESS: StringName = &"success"
const STATUS_INVALID_CONSTRUCTION_RESULT: StringName = &"invalid_construction_result"
const STATUS_MALFORMED_FOOTPRINT: StringName = &"malformed_footprint"
const STATUS_OCCUPIED_FOOTPRINT: StringName = &"occupied_footprint"

var _status: StringName
var _record: BuildingInstanceRecord


func _init(status: StringName, record: BuildingInstanceRecord = null) -> void:
	_status = status
	_record = record


func get_status() -> StringName:
	return _status


func is_success() -> bool:
	return _status == STATUS_SUCCESS


func get_record() -> BuildingInstanceRecord:
	return _record
