class_name BuildingRegistry
extends RefCounted

var _records: Array[BuildingInstanceRecord] = []
var _records_by_id: Dictionary = {}
var _records_by_cell: Dictionary = {}
var _occupied_cells: Array[Vector2i] = []
var _next_instance_id: int = 1


func register(construction_result: BuildingConstructionResult) -> BuildingRegistrationResult:
	if construction_result == null or not construction_result.is_success() or construction_result.get_building_id().is_empty():
		return BuildingRegistrationResult.new(BuildingRegistrationResult.STATUS_INVALID_CONSTRUCTION_RESULT)

	var candidate_cells: Array = construction_result.get_footprint_cells()
	if candidate_cells.is_empty():
		return BuildingRegistrationResult.new(BuildingRegistrationResult.STATUS_MALFORMED_FOOTPRINT)
	var validated_cells: Array[Vector2i] = []
	var unique_cells: Dictionary = {}
	for candidate: Variant in candidate_cells:
		if typeof(candidate) != TYPE_VECTOR2I or unique_cells.has(candidate):
			return BuildingRegistrationResult.new(BuildingRegistrationResult.STATUS_MALFORMED_FOOTPRINT)
		unique_cells[candidate] = true
		validated_cells.append(candidate)

	for cell: Vector2i in validated_cells:
		if _records_by_cell.has(cell):
			return BuildingRegistrationResult.new(BuildingRegistrationResult.STATUS_OCCUPIED_FOOTPRINT)

	var record := BuildingInstanceRecord.new(
		_next_instance_id,
		construction_result.get_building_id(),
		construction_result.get_anchor(),
		validated_cells
	)
	_records.append(record)
	_records_by_id[record.get_registry_instance_id()] = record
	for cell: Vector2i in validated_cells:
		_records_by_cell[cell] = record
		_occupied_cells.append(cell)
	_next_instance_id += 1
	return BuildingRegistrationResult.new(BuildingRegistrationResult.STATUS_SUCCESS, record)


func get_record_by_instance_id(instance_id: int) -> BuildingInstanceRecord:
	return _records_by_id.get(instance_id) as BuildingInstanceRecord


func get_record_by_occupied_cell(cell: Vector2i) -> BuildingInstanceRecord:
	return _records_by_cell.get(cell) as BuildingInstanceRecord


func get_records() -> Array[BuildingInstanceRecord]:
	return _records.duplicate()


func get_occupied_cells() -> Array[Vector2i]:
	return _occupied_cells.duplicate()


func get_record_count() -> int:
	return _records.size()
