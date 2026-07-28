extends SceneTree

const RESOURCE_DATA_PATH := "res://data/resources/resource_definitions.json"
const BUILDING_DATA_PATH := "res://data/buildings/building_definitions.json"
const EXPECTED_CELLS: Array[Vector2i] = [Vector2i(1, 2), Vector2i(2, 2), Vector2i(1, 3), Vector2i(2, 3)]


func _initialize() -> void:
	var resources := ResourceCatalog.new()
	if not resources.load_from_file(RESOURCE_DATA_PATH):
		_fail("Resource prerequisite failed")
		return
	var buildings := BuildingCatalog.new()
	if not buildings.load_from_file(BUILDING_DATA_PATH, resources):
		_fail("Building prerequisite failed")
		return
	var validator := BuildingPlacementValidator.new()
	var occupied: Array = [Vector2i(0, 0)]
	var occupied_before: Array = occupied.duplicate(true)

	var ledger := _funded_ledger(resources, 75, 30, 7)
	var executor := BuildingConstructionExecutor.new(buildings, validator, ledger)
	var result: BuildingConstructionResult = executor.construct("basic_nest", Vector2i(1, 2), Vector2i(5, 5), occupied)
	if not result.is_success() or result.get_building_id() != "basic_nest" or result.get_anchor() != Vector2i(1, 2) or result.get_footprint_cells() != EXPECTED_CELLS:
		_fail("Valid Basic Nest construction returned incorrect semantics")
		return
	if ledger.get_balance_snapshot() != {"crumbs": 50, "twigs": 20, "shinies": 7} or occupied != occupied_before:
		_fail("Valid construction did not apply the exact isolated debit")
		return
	var returned_cells: Array[Vector2i] = result.get_footprint_cells()
	returned_cells.clear()
	if result.get_footprint_cells() != EXPECTED_CELLS:
		_fail("Construction result leaked mutable footprint state")
		return

	for invalid_case: Array in [[Vector2i(4, 4), []], [Vector2i(1, 2), [Vector2i(2, 3)]]]:
		var before: Dictionary = ledger.get_balance_snapshot()
		var supplied_occupancy: Array = invalid_case[1]
		var supplied_before: Array = supplied_occupancy.duplicate(true)
		var rejected: BuildingConstructionResult = executor.construct("basic_nest", invalid_case[0], Vector2i(5, 5), supplied_occupancy)
		if rejected.get_status() != BuildingConstructionResult.STATUS_INVALID_PLACEMENT or ledger.get_balance_snapshot() != before or supplied_occupancy != supplied_before:
			_fail("Invalid placement was not rejected before debit")
			return

	for balances: Array in [[24, 10], [25, 9]]:
		var insufficient := _funded_ledger(resources, balances[0], balances[1], 5)
		var insufficient_executor := BuildingConstructionExecutor.new(buildings, validator, insufficient)
		var before: Dictionary = insufficient.get_balance_snapshot()
		var rejected: BuildingConstructionResult = insufficient_executor.construct("basic_nest", Vector2i(1, 1), Vector2i(4, 4), occupied)
		if rejected.get_status() != BuildingConstructionResult.STATUS_INSUFFICIENT_RESOURCES or insufficient.get_balance_snapshot() != before:
			_fail("Insufficient construction debit was not atomic")
			return

	for bad_id: String in ["", "unknown_building"]:
		var before: Dictionary = ledger.get_balance_snapshot()
		if executor.construct(bad_id, Vector2i.ZERO, Vector2i(4, 4), occupied).get_status() != BuildingConstructionResult.STATUS_INVALID_BUILDING_ID or ledger.get_balance_snapshot() != before:
			_fail("Invalid building ID rejection was unstable")
			return
	var missing_executors: Array = [
		BuildingConstructionExecutor.new(null, validator, ledger),
		BuildingConstructionExecutor.new(buildings, null, ledger),
		BuildingConstructionExecutor.new(buildings, validator, null),
	]
	for missing: BuildingConstructionExecutor in missing_executors:
		var before: Dictionary = ledger.get_balance_snapshot()
		if missing.construct("basic_nest", Vector2i.ZERO, Vector2i(4, 4), occupied).get_status() != BuildingConstructionResult.STATUS_MISSING_DEPENDENCY or ledger.get_balance_snapshot() != before:
			_fail("Missing dependency rejection was unstable")
			return

	var repeated_ledger := _funded_ledger(resources, 50, 20, 6)
	var repeated := BuildingConstructionExecutor.new(buildings, validator, repeated_ledger)
	if not repeated.construct("basic_nest", Vector2i(1, 1), Vector2i(4, 4), occupied).is_success() or not repeated.construct("basic_nest", Vector2i(1, 1), Vector2i(4, 4), occupied).is_success():
		_fail("Affordable repeated construction was rejected")
		return
	var depleted: Dictionary = repeated_ledger.get_balance_snapshot()
	if repeated.construct("basic_nest", Vector2i(1, 1), Vector2i(4, 4), occupied).get_status() != BuildingConstructionResult.STATUS_INSUFFICIENT_RESOURCES or repeated_ledger.get_balance_snapshot() != depleted:
		_fail("Unaffordable repeat was not rejected atomically")
		return

	var substituted_entries: Array = _read_building_entries()
	if substituted_entries.is_empty():
		return
	var substituted: Dictionary = substituted_entries[0]
	substituted["display_name"] = "Replacement Name"
	substituted["description"] = "Replacement description"
	substituted["icon_slot"] = "replacement.icon"
	substituted["style_slot"] = "replacement.style"
	substituted["world_visual_slot"] = "replacement.world"
	var substituted_catalog := BuildingCatalog.new()
	if not substituted_catalog.load_from_entries(substituted_entries, resources):
		_fail("Presentation-substituted catalog failed")
		return
	var substituted_ledger := _funded_ledger(resources, 25, 10, 4)
	var substituted_result: BuildingConstructionResult = BuildingConstructionExecutor.new(substituted_catalog, validator, substituted_ledger).construct("basic_nest", Vector2i(1, 2), Vector2i(5, 5), occupied)
	if not substituted_result.is_success() or substituted_result.get_footprint_cells() != EXPECTED_CELLS or substituted_ledger.get_balance_snapshot() != {"crumbs": 0, "twigs": 0, "shinies": 4}:
		_fail("Presentation substitution changed construction mechanics")
		return
	if occupied != occupied_before:
		_fail("Executor mutated caller-owned occupancy")
		return

	print("PHASE03_BUILDING_CONSTRUCTION_EXECUTOR_SMOKE PASS")
	quit(0)


func _funded_ledger(resources: ResourceCatalog, crumbs: int, twigs: int, shinies: int) -> ResourceLedger:
	var ledger := ResourceLedger.new(resources)
	if crumbs > 0:
		ledger.credit("crumbs", crumbs)
	if twigs > 0:
		ledger.credit("twigs", twigs)
	if shinies > 0:
		ledger.credit("shinies", shinies)
	return ledger


func _read_building_entries() -> Array:
	var file := FileAccess.open(BUILDING_DATA_PATH, FileAccess.READ)
	var parser := JSON.new()
	if file == null or parser.parse(file.get_as_text()) != OK or typeof(parser.data) != TYPE_ARRAY:
		_fail("Could not read authoritative building data")
		return []
	return parser.data


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
