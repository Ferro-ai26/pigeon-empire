extends SceneTree

const BUILDING_DATA_PATH := "res://data/buildings/building_definitions.json"
const RESOURCE_DATA_PATH := "res://data/resources/resource_definitions.json"


func _initialize() -> void:
	var resources := ResourceCatalog.new()
	if not resources.load_from_file(RESOURCE_DATA_PATH):
		_fail("Resource prerequisite failed")
		return
	var catalog := BuildingCatalog.new()
	if not catalog.load_from_file(BUILDING_DATA_PATH, resources):
		_fail("Authoritative building catalog failed: %s" % catalog.get_last_error())
		return
	if catalog.size() != 1 or _catalog_ids(catalog) != ["basic_nest"]:
		_fail("Authoritative membership or order changed")
		return
	var nest: BuildingDefinition = catalog.get_definition("basic_nest")
	if nest == null or nest.get_footprint_width() != 2 or nest.get_footprint_height() != 2:
		_fail("Basic Nest footprint changed")
		return
	if nest.get_construction_costs() != {"crumbs": 25, "twigs": 10} or nest.get_storage_contributions() != {"crumbs": 50, "twigs": 25, "shinies": 0}:
		_fail("Basic Nest costs or storage changed")
		return
	if catalog.get_definition("unknown") != null or catalog.size() != 1:
		_fail("Unknown lookup mutated catalog")
		return
	var order := catalog.get_ordered_definitions()
	order.clear()
	var costs := nest.get_construction_costs()
	costs["crumbs"] = 999
	var storage := nest.get_storage_contributions()
	storage.clear()
	if catalog.size() != 1 or nest.get_construction_costs()["crumbs"] != 25 or nest.get_storage_contributions().size() != 3:
		_fail("Published collections were mutable")
		return

	var valid := _read_entries()
	if valid.is_empty():
		return
	var cases: Array = [
		["duplicate", _duplicate(valid)], ["missing", _mutate(valid, "erase", "id", null)],
		["empty_id", _mutate(valid, "set", "id", "")], ["fractional_width", _mutate(valid, "set", "footprint_width", 1.5)],
		["zero_width", _mutate(valid, "set", "footprint_width", 0)], ["string_height", _mutate(valid, "set", "footprint_height", "2")],
		["empty_costs", _mutate(valid, "set", "construction_costs", {})], ["fractional_cost", _map_mutate(valid, "construction_costs", "crumbs", 1.5)],
		["zero_cost", _map_mutate(valid, "construction_costs", "crumbs", 0)], ["unknown_cost", _map_mutate(valid, "construction_costs", "feathers", 1)],
		["negative_storage", _map_mutate(valid, "storage_contributions", "crumbs", -1)], ["all_zero_storage", _mutate(valid, "set", "storage_contributions", {"crumbs": 0})],
		["invalid_metadata", _mutate(valid, "set", "icon_slot", false)], ["malformed_map", _mutate(valid, "set", "construction_costs", [])],
		["overflow", _mutate(valid, "set", "footprint_width", 1.0e30)], ["malformed_entry", ["bad"]],
	]
	for test_case: Array in cases:
		if catalog.load_from_entries(test_case[1], resources):
			_fail("Accepted invalid case: %s" % test_case[0])
			return
		if catalog.size() != 1 or _catalog_ids(catalog) != ["basic_nest"] or catalog.get_definition("basic_nest").get_construction_costs()["crumbs"] != 25:
			_fail("Rejected case replaced published state: %s" % test_case[0])
			return
	if catalog.load_from_entries(valid, null):
		_fail("Accepted missing resource catalog")
		return

	var substituted: Array = valid.duplicate(true)
	var entry: Dictionary = substituted[0]
	entry["display_name"] = "Temporary Nest Label"
	entry["description"] = "Temporary description"
	entry["icon_slot"] = "test.icon"
	entry["style_slot"] = "test.style"
	entry["world_visual_slot"] = "test.world"
	var reskinned := BuildingCatalog.new()
	if not reskinned.load_from_entries(substituted, resources):
		_fail("Presentation substitution failed")
		return
	var changed: BuildingDefinition = reskinned.get_definition("basic_nest")
	if changed.get_display_name() != "Temporary Nest Label" or changed.get_semantic_id() != nest.get_semantic_id() or changed.get_footprint_width() != nest.get_footprint_width() or changed.get_footprint_height() != nest.get_footprint_height() or changed.get_construction_costs() != nest.get_construction_costs() or changed.get_storage_contributions() != nest.get_storage_contributions() or _catalog_ids(reskinned) != ["basic_nest"]:
		_fail("Presentation substitution changed mechanics")
		return
	print("PHASE03_BUILDING_CATALOG_SMOKE PASS")
	quit(0)


func _read_entries() -> Array:
	var file := FileAccess.open(BUILDING_DATA_PATH, FileAccess.READ)
	var parser := JSON.new()
	if file == null or parser.parse(file.get_as_text()) != OK or typeof(parser.data) != TYPE_ARRAY:
		_fail("Could not read authoritative building data")
		return []
	return parser.data


func _catalog_ids(catalog: BuildingCatalog) -> Array[String]:
	var ids: Array[String] = []
	for definition: BuildingDefinition in catalog.get_ordered_definitions():
		ids.append(definition.get_semantic_id())
	return ids


func _duplicate(entries: Array) -> Array:
	var result := entries.duplicate(true)
	result.append(result[0].duplicate(true))
	return result


func _mutate(entries: Array, operation: String, field: String, value: Variant) -> Array:
	var result := entries.duplicate(true)
	if operation == "erase":
		result[0].erase(field)
	else:
		result[0][field] = value
	return result


func _map_mutate(entries: Array, field: String, key: String, value: Variant) -> Array:
	var result := entries.duplicate(true)
	result[0][field][key] = value
	return result


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
