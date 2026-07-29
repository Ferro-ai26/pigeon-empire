extends SceneTree

const RESOURCE_DATA_PATH := "res://data/resources/resource_definitions.json"
const BUILDING_DATA_PATH := "res://data/buildings/building_definitions.json"
const FIRST_CELLS: Array[Vector2i] = [Vector2i(1, 2), Vector2i(2, 2), Vector2i(1, 3), Vector2i(2, 3)]
const SECOND_CELLS: Array[Vector2i] = [Vector2i(4, 1), Vector2i(5, 1), Vector2i(4, 2), Vector2i(5, 2)]


func _initialize() -> void:
	var resources := ResourceCatalog.new()
	var buildings := BuildingCatalog.new()
	if not resources.load_from_file(RESOURCE_DATA_PATH) or not buildings.load_from_file(BUILDING_DATA_PATH, resources):
		_fail("Catalog prerequisite failed")
		return
	var registry := BuildingRegistry.new()
	var source_cells: Array[Vector2i] = FIRST_CELLS.duplicate()
	var first_construction := _successful_construction(buildings, resources, Vector2i(1, 2))
	if first_construction == null or first_construction.get_footprint_cells() != source_cells:
		_fail("Authoritative Basic Nest construction prerequisite failed")
		return
	var first_result: BuildingRegistrationResult = registry.register(first_construction)
	var first: BuildingInstanceRecord = first_result.get_record()
	if not first_result.is_success() or first == null or first.get_registry_instance_id() != 1 or first.get_building_id() != "basic_nest" or first.get_anchor() != Vector2i(1, 2) or first.get_footprint_cells() != FIRST_CELLS:
		_fail("First registration published incorrect semantics")
		return
	for cell: Vector2i in FIRST_CELLS:
		if registry.get_record_by_occupied_cell(cell) != first:
			_fail("Occupied-cell lookup did not resolve the first record")
			return
	if registry.get_record_by_occupied_cell(Vector2i(9, 9)) != null or registry.get_record_by_instance_id(999) != null or registry.get_record_count() != 1:
		_fail("Unknown lookup mutated or resolved registry state")
		return

	var second_result: BuildingRegistrationResult = registry.register(_successful_construction(buildings, resources, Vector2i(4, 1)))
	var second: BuildingInstanceRecord = second_result.get_record()
	if not second_result.is_success() or second == null or second.get_registry_instance_id() != 2 or second.get_footprint_cells() != SECOND_CELLS or registry.get_records() != [first, second]:
		_fail("Second registration did not preserve deterministic identity and order")
		return
	var stable_records: Array[BuildingInstanceRecord] = registry.get_records()
	var stable_cells: Array[Vector2i] = registry.get_occupied_cells()
	var overlap := BuildingConstructionResult.new(BuildingConstructionResult.STATUS_SUCCESS, "basic_nest", Vector2i(2, 3), [Vector2i(2, 3), Vector2i(3, 3)])
	if registry.register(overlap).get_status() != BuildingRegistrationResult.STATUS_OCCUPIED_FOOTPRINT or registry.get_records() != stable_records or registry.get_occupied_cells() != stable_cells:
		_fail("Overlap rejection was not atomic")
		return

	var invalid_cases: Array = [
		null,
		BuildingConstructionResult.new(BuildingConstructionResult.STATUS_INVALID_PLACEMENT, "basic_nest", Vector2i.ZERO, FIRST_CELLS),
		BuildingConstructionResult.new(BuildingConstructionResult.STATUS_SUCCESS, "", Vector2i.ZERO, FIRST_CELLS),
		BuildingConstructionResult.new(BuildingConstructionResult.STATUS_SUCCESS, "basic_nest", Vector2i.ZERO, []),
		BuildingConstructionResult.new(BuildingConstructionResult.STATUS_SUCCESS, "basic_nest", Vector2i.ZERO, [Vector2i(8, 8), Vector2i(8, 8)]),
	]
	for invalid: Variant in invalid_cases:
		var before_records: Array[BuildingInstanceRecord] = registry.get_records()
		var before_cells: Array[Vector2i] = registry.get_occupied_cells()
		var rejected: BuildingRegistrationResult = registry.register(invalid)
		var expected := BuildingRegistrationResult.STATUS_MALFORMED_FOOTPRINT if invalid != null and invalid.is_success() and not invalid.get_building_id().is_empty() else BuildingRegistrationResult.STATUS_INVALID_CONSTRUCTION_RESULT
		if rejected.get_status() != expected or registry.get_records() != before_records or registry.get_occupied_cells() != before_cells:
			_fail("Invalid registration changed registry state")
			return

	var copied_records: Array[BuildingInstanceRecord] = registry.get_records()
	var copied_occupied: Array[Vector2i] = registry.get_occupied_cells()
	var copied_footprint: Array[Vector2i] = first.get_footprint_cells()
	copied_records.clear()
	copied_occupied.clear()
	copied_footprint.clear()
	source_cells.clear()
	if registry.get_record_count() != 2 or registry.get_records() != [first, second] or registry.get_occupied_cells() != stable_cells or first.get_footprint_cells() != FIRST_CELLS:
		_fail("Caller mutation leaked into registry state")
		return

	var third := BuildingConstructionResult.new(BuildingConstructionResult.STATUS_SUCCESS, "basic_nest", Vector2i(8, 8), [Vector2i(8, 8)])
	var third_record: BuildingInstanceRecord = registry.register(third).get_record()
	if third_record == null or third_record.get_registry_instance_id() != 3:
		_fail("Rejected registrations consumed an instance ID")
		return

	var substituted_entries: Array = _read_building_entries()
	if substituted_entries.is_empty():
		return
	var entry: Dictionary = substituted_entries[0]
	entry["display_name"] = "Replacement Name"
	entry["description"] = "Replacement description"
	entry["icon_slot"] = "replacement.icon"
	entry["style_slot"] = "replacement.style"
	entry["world_visual_slot"] = "replacement.world"
	var substituted_catalog := BuildingCatalog.new()
	if not substituted_catalog.load_from_entries(substituted_entries, resources):
		_fail("Presentation-substituted catalog failed")
		return
	var substituted_registry := BuildingRegistry.new()
	var substituted_result: BuildingRegistrationResult = substituted_registry.register(_successful_construction(substituted_catalog, resources, Vector2i(1, 2)))
	var substituted_record: BuildingInstanceRecord = substituted_result.get_record()
	if substituted_record == null or substituted_record.get_registry_instance_id() != 1 or substituted_record.get_building_id() != "basic_nest" or substituted_record.get_footprint_cells() != FIRST_CELLS:
		_fail("Presentation metadata changed registry mechanics")
		return

	print("PHASE03_BUILDING_REGISTRY_SMOKE PASS")
	quit(0)


func _successful_construction(buildings: BuildingCatalog, resources: ResourceCatalog, anchor: Vector2i) -> BuildingConstructionResult:
	var ledger := ResourceLedger.new(resources)
	ledger.credit("crumbs", 25)
	ledger.credit("twigs", 10)
	return BuildingConstructionExecutor.new(buildings, BuildingPlacementValidator.new(), ledger).construct("basic_nest", anchor, Vector2i(10, 10), [])


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
