extends SceneTree

const ACTION_DATA_PATH := "res://data/resources/gathering_action_definitions.json"
const RESOURCE_DATA_PATH := "res://data/resources/resource_definitions.json"
const EXPECTED_IDS: Array[String] = ["gather_crumbs", "gather_twigs", "gather_shinies"]
const EXPECTED_RESOURCES: Array[String] = ["crumbs", "twigs", "shinies"]


func _initialize() -> void:
	var resources := ResourceCatalog.new()
	if not resources.load_from_file(RESOURCE_DATA_PATH):
		_fail("Authoritative resource catalog failed: %s" % resources.get_last_error())
		return
	var catalog := GatheringActionCatalog.new()
	if not catalog.load_from_file(ACTION_DATA_PATH, resources):
		_fail("Authoritative action catalog failed: %s" % catalog.get_last_error())
		return
	if catalog.size() != 3 or catalog.get_ordered_ids() != EXPECTED_IDS:
		_fail("Authoritative action membership or source order is incorrect")
		return
	var definitions: Array[GatheringActionDefinition] = catalog.get_ordered_definitions()
	for index: int in definitions.size():
		var definition: GatheringActionDefinition = definitions[index]
		if definition.get_action_id() != EXPECTED_IDS[index] or definition.get_resource_id() != EXPECTED_RESOURCES[index] or definition.get_reward_amount() <= 0:
			_fail("Typed action mechanics do not match authoritative data")
			return
	var known: GatheringActionDefinition = catalog.get_definition("gather_crumbs")
	if known == null or known.get_reward_amount() != 1 or known.get_icon_slot().is_empty():
		_fail("Known typed lookup or metadata contract failed")
		return
	var count_before: int = catalog.size()
	if catalog.get_definition("unknown") != null or catalog.size() != count_before or catalog.get_ordered_ids() != EXPECTED_IDS:
		_fail("Unknown lookup mutated the catalog")
		return
	var copied_definitions: Array[GatheringActionDefinition] = catalog.get_ordered_definitions()
	var copied_ids: Array[String] = catalog.get_ordered_ids()
	copied_definitions.clear()
	copied_ids.reverse()
	if catalog.size() != count_before or catalog.get_ordered_ids() != EXPECTED_IDS:
		_fail("Catalog exposed mutable ordered storage")
		return

	var valid: Array = _read_entries()
	if valid.is_empty():
		return
	var cases: Array[Dictionary] = []
	cases.append(_case(_append_duplicate(valid), "duplicate_gathering_action_id_gather_crumbs"))
	cases.append(_case(_changed(valid, 0, "id", ""), "entry_0_id_must_not_be_empty"))
	cases.append(_case(_changed(valid, 0, "resource_id", "unknown"), "entry_0_unknown_resource_id_unknown"))
	cases.append(_case(_changed(valid, 0, "reward_amount", 0), "entry_0_reward_amount_must_be_positive"))
	cases.append(_case(_changed(valid, 0, "reward_amount", -1), "entry_0_reward_amount_must_be_positive"))
	cases.append(_case(_changed(valid, 0, "reward_amount", 1.5), "entry_0_reward_amount_must_be_integer"))
	cases.append(_case(_without(valid, 0, "resource_id"), "entry_0_missing_resource_id"))
	cases.append(_case(_changed(valid, 0, "display_name", 7), "entry_0_display_name_must_be_string"))
	var malformed: Array = valid.duplicate(true)
	malformed[0] = "not_an_object"
	cases.append(_case(malformed, "entry_0_must_be_object"))
	for rejection: Dictionary in cases:
		if not _expect_rejection(catalog, rejection["entries"], rejection["error"], resources):
			return
	if catalog.load_from_json_text("{}", resources) or catalog.get_last_error() != "gathering_action_root_must_be_array" or not _is_original(catalog):
		_fail("Malformed root did not reject atomically")
		return
	if catalog.load_from_json_text("[", resources) or catalog.get_last_error() != "gathering_action_file_invalid_json" or not _is_original(catalog):
		_fail("Invalid JSON did not reject atomically")
		return
	if catalog.load_from_entries(valid, null) or catalog.get_last_error() != "authoritative_resource_catalog_required" or not _is_original(catalog):
		_fail("Missing authoritative resource catalog did not reject atomically")
		return

	var substituted: Array = valid.duplicate(true)
	for index: int in substituted.size():
		substituted[index]["display_name"] = "Temporary Label %d" % index
		substituted[index]["short_description"] = "Temporary description %d" % index
		substituted[index]["icon_slot"] = "test.action.%d.icon" % index
		substituted[index]["style_slot"] = "test.action.%d.style" % index
	var reskinned := GatheringActionCatalog.new()
	if not reskinned.load_from_entries(substituted, resources) or not _same_mechanics(catalog, reskinned):
		_fail("Presentation metadata substitution changed mechanics, lookup, validation, or order")
		return
	print("PHASE02_GATHERING_ACTION_CATALOG_SMOKE PASS")
	quit(0)


func _read_entries() -> Array:
	var file := FileAccess.open(ACTION_DATA_PATH, FileAccess.READ)
	if file == null:
		_fail("Could not read authoritative action data")
		return []
	var parser := JSON.new()
	if parser.parse(file.get_as_text()) != OK or typeof(parser.data) != TYPE_ARRAY:
		_fail("Authoritative action data is not a JSON array")
		return []
	return parser.data


func _changed(entries: Array, index: int, field: String, value: Variant) -> Array:
	var changed: Array = entries.duplicate(true)
	changed[index][field] = value
	return changed


func _without(entries: Array, index: int, field: String) -> Array:
	var changed: Array = entries.duplicate(true)
	changed[index].erase(field)
	return changed


func _append_duplicate(entries: Array) -> Array:
	var changed: Array = entries.duplicate(true)
	changed.append(changed[0].duplicate(true))
	return changed


func _case(entries: Array, expected_error: String) -> Dictionary:
	return {"entries": entries, "error": expected_error}


func _expect_rejection(catalog: GatheringActionCatalog, entries: Array, expected_error: String, resources: ResourceCatalog) -> bool:
	if catalog.load_from_entries(entries, resources):
		_fail("Malformed data was accepted: %s" % expected_error)
		return false
	if catalog.get_last_error() != expected_error:
		_fail("Expected %s, got %s" % [expected_error, catalog.get_last_error()])
		return false
	if not _is_original(catalog):
		_fail("Rejected reload replaced previously published state")
		return false
	return true


func _is_original(catalog: GatheringActionCatalog) -> bool:
	if catalog.get_ordered_ids() != EXPECTED_IDS:
		return false
	var definitions: Array[GatheringActionDefinition] = catalog.get_ordered_definitions()
	for index: int in definitions.size():
		if definitions[index].get_resource_id() != EXPECTED_RESOURCES[index] or definitions[index].get_reward_amount() != 1:
			return false
	return true


func _same_mechanics(first: GatheringActionCatalog, second: GatheringActionCatalog) -> bool:
	if first.get_ordered_ids() != second.get_ordered_ids():
		return false
	for action_id: String in EXPECTED_IDS:
		var left: GatheringActionDefinition = first.get_definition(action_id)
		var right: GatheringActionDefinition = second.get_definition(action_id)
		if left == null or right == null or left.get_resource_id() != right.get_resource_id() or left.get_reward_amount() != right.get_reward_amount():
			return false
	return second.get_definition("unknown") == null


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
