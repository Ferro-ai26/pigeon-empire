class_name BuildingConstructionExecutor
extends RefCounted

var _catalog: BuildingCatalog
var _placement_validator: BuildingPlacementValidator
var _ledger: ResourceLedger


func _init(catalog: BuildingCatalog, placement_validator: BuildingPlacementValidator, ledger: ResourceLedger) -> void:
	_catalog = catalog
	_placement_validator = placement_validator
	_ledger = ledger


func construct(building_id: String, anchor: Vector2i, grid_bounds: Vector2i, occupied_cells: Array) -> BuildingConstructionResult:
	if _catalog == null or _placement_validator == null or _ledger == null:
		return _result(BuildingConstructionResult.STATUS_MISSING_DEPENDENCY, building_id, anchor, [])
	if building_id.is_empty():
		return _result(BuildingConstructionResult.STATUS_INVALID_BUILDING_ID, building_id, anchor, [])
	var definition: BuildingDefinition = _catalog.get_definition(building_id)
	if definition == null:
		return _result(BuildingConstructionResult.STATUS_INVALID_BUILDING_ID, building_id, anchor, [])

	var placement: BuildingPlacementResult = _placement_validator.validate(definition, anchor, grid_bounds, occupied_cells)
	if not placement.is_valid():
		return _result(BuildingConstructionResult.STATUS_INVALID_PLACEMENT, building_id, anchor, placement.get_footprint_cells())

	var transaction_status: StringName = _ledger.debit_bundle(definition.get_construction_costs())
	if transaction_status == ResourceLedger.BUNDLE_DEBIT_INSUFFICIENT_BALANCE:
		return _result(BuildingConstructionResult.STATUS_INSUFFICIENT_RESOURCES, building_id, anchor, placement.get_footprint_cells())
	if transaction_status != ResourceLedger.BUNDLE_DEBIT_SUCCESS:
		return _result(BuildingConstructionResult.STATUS_COST_TRANSACTION_REJECTED, building_id, anchor, placement.get_footprint_cells())
	return _result(BuildingConstructionResult.STATUS_SUCCESS, building_id, anchor, placement.get_footprint_cells())


func _result(status: StringName, building_id: String, anchor: Vector2i, cells: Array[Vector2i]) -> BuildingConstructionResult:
	return BuildingConstructionResult.new(status, building_id, anchor, cells)
