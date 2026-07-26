extends SceneTree

const BUILDING_DATA_PATH := "res://data/buildings/building_definitions.json"
const RESOURCE_DATA_PATH := "res://data/resources/resource_definitions.json"
const GRID_BOUNDS := Vector2i(5, 5)
const EXPECTED_CELLS: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]


func _initialize() -> void:
	var resources := ResourceCatalog.new()
	var catalog := BuildingCatalog.new()
	if not resources.load_from_file(RESOURCE_DATA_PATH) or not catalog.load_from_file(BUILDING_DATA_PATH, resources):
		_fail("Could not load authoritative catalogs")
		return
	var nest: BuildingDefinition = catalog.get_definition("basic_nest")
	var validator := BuildingPlacementValidator.new()
	var occupancy: Array = [Vector2i(4, 4), Vector2i(4, 4)]
	var occupancy_before: Array = occupancy.duplicate(true)
	var definition_before := _definition_snapshot(nest)

	var origin := validator.validate(nest, Vector2i.ZERO, GRID_BOUNDS, occupancy)
	if not origin.is_valid() or origin.get_status() != BuildingPlacementResult.STATUS_VALID or origin.get_anchor() != Vector2i.ZERO or origin.get_footprint_cells() != EXPECTED_CELLS:
		_fail("Origin placement or row-major footprint failed")
		return
	if not validator.validate(nest, Vector2i(3, 3), GRID_BOUNDS, []).is_valid():
		_fail("Bottom-right valid boundary failed")
		return
	for anchor: Vector2i in [Vector2i(4, 3), Vector2i(3, 4), Vector2i(-1, 0), Vector2i(0, -1)]:
		if validator.validate(nest, anchor, GRID_BOUNDS, []).get_status() != BuildingPlacementResult.STATUS_OUT_OF_BOUNDS:
			_fail("Out-of-bounds anchor accepted: %s" % anchor)
			return
	if validator.validate(nest, Vector2i.ZERO, GRID_BOUNDS, [Vector2i(2, 2)]).get_status() != BuildingPlacementResult.STATUS_VALID:
		_fail("Unrelated occupancy blocked placement")
		return
	for cell: Vector2i in EXPECTED_CELLS:
		if validator.validate(nest, Vector2i.ZERO, GRID_BOUNDS, [cell, cell]).get_status() != BuildingPlacementResult.STATUS_OCCUPIED_CONFLICT:
			_fail("Overlap was not rejected: %s" % cell)
			return
	if validator.validate(nest, Vector2i.ZERO, GRID_BOUNDS, ["0,0"]).get_status() != BuildingPlacementResult.STATUS_OCCUPIED_CONFLICT:
		_fail("Malformed occupancy was accepted")
		return

	var malformed := BuildingDefinition.new("bad", 0, 2, {}, {}, "x", "x", "x", "x", "x")
	if validator.validate(null, Vector2i.ZERO, GRID_BOUNDS, []).get_status() != BuildingPlacementResult.STATUS_INVALID_DEFINITION or validator.validate(malformed, Vector2i.ZERO, GRID_BOUNDS, []).get_status() != BuildingPlacementResult.STATUS_INVALID_DEFINITION:
		_fail("Invalid definition was accepted")
		return
	for bounds: Vector2i in [Vector2i.ZERO, Vector2i(0, 5), Vector2i(5, 0), Vector2i(-1, 5), Vector2i(5, -1)]:
		if validator.validate(nest, Vector2i.ZERO, bounds, []).get_status() != BuildingPlacementResult.STATUS_INVALID_GRID_BOUNDS:
			_fail("Invalid grid bounds accepted: %s" % bounds)
			return

	var exposed := origin.get_footprint_cells()
	exposed.clear()
	if origin.get_footprint_cells() != EXPECTED_CELLS or not validator.validate(nest, Vector2i.ZERO, GRID_BOUNDS, []).is_valid():
		_fail("Result collection leaked mutable state")
		return
	if occupancy != occupancy_before or _definition_snapshot(nest) != definition_before:
		_fail("Validation mutated an input")
		return

	var substituted := BuildingDefinition.new(
		nest.get_semantic_id(), nest.get_footprint_width(), nest.get_footprint_height(),
		nest.get_construction_costs(), nest.get_storage_contributions(), "Temporary Label",
		"Temporary description", "test.icon", "test.style", "test.world"
	)
	var reskinned := validator.validate(substituted, Vector2i.ZERO, GRID_BOUNDS, occupancy)
	if reskinned.get_status() != origin.get_status() or reskinned.get_anchor() != origin.get_anchor() or reskinned.get_footprint_cells() != origin.get_footprint_cells():
		_fail("Presentation metadata changed placement mechanics")
		return

	print("PHASE03_BUILDING_PLACEMENT_VALIDATOR_SMOKE PASS")
	quit(0)


func _definition_snapshot(definition: BuildingDefinition) -> Array:
	return [definition.get_semantic_id(), definition.get_footprint_width(), definition.get_footprint_height(), definition.get_construction_costs(), definition.get_storage_contributions(), definition.get_display_name(), definition.get_description(), definition.get_icon_slot(), definition.get_style_slot(), definition.get_world_visual_slot()]


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
