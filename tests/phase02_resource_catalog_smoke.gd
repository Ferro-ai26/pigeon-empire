extends SceneTree

const RESOURCE_DATA_PATH := "res://data/resources/resource_definitions.json"


func _initialize() -> void:
	var catalog := ResourceCatalog.new()
	if not catalog.load_from_file(RESOURCE_DATA_PATH):
		_fail("Authoritative catalog failed: %s" % catalog.get_last_error())
		return
	if catalog.size() != 3:
		_fail("Authoritative catalog must contain exactly the three mandated resources")
		return
	var expected_ids: Array[String] = ["crumbs", "twigs", "shinies"]
	if _catalog_ids(catalog) != expected_ids:
		_fail("Catalog did not preserve deterministic source order")
		return
	var crumbs: ResourceDefinition = catalog.get_definition("crumbs")
	if crumbs == null or crumbs.get_semantic_id() != "crumbs":
		_fail("Known lookup did not return the exact semantic definition")
		return
	if crumbs.get_display_name().is_empty() or crumbs.get_short_description().is_empty() or crumbs.get_icon_slot() != "resource.crumbs.icon" or crumbs.get_style_slot() != "resource.crumbs.style":
		_fail("Typed presentation metadata is incomplete")
		return
	var count_before: int = catalog.size()
	if catalog.get_definition("unknown") != null or catalog.size() != count_before:
		_fail("Unknown lookup was not a safe non-mutating null result")
		return
	var returned_order: Array[ResourceDefinition] = catalog.get_ordered_definitions()
	returned_order.clear()
	if catalog.size() != count_before:
		_fail("Ordered enumeration exposed mutable catalog storage")
		return

	var valid_entries: Array = _read_entries()
	if valid_entries.is_empty():
		return
	var duplicate_entries: Array = valid_entries.duplicate(true)
	duplicate_entries.append(duplicate_entries[0].duplicate(true))
	if not _expect_rejection(catalog, duplicate_entries, "duplicate_resource_id_crumbs", expected_ids):
		return
	var missing_field_entries: Array = valid_entries.duplicate(true)
	missing_field_entries[0].erase("display_name")
	if not _expect_rejection(catalog, missing_field_entries, "entry_0_missing_display_name", expected_ids):
		return
	var empty_id_entries: Array = valid_entries.duplicate(true)
	empty_id_entries[0]["id"] = ""
	if not _expect_rejection(catalog, empty_id_entries, "entry_0_id_must_not_be_empty", expected_ids):
		return
	var invalid_type_entries: Array = valid_entries.duplicate(true)
	invalid_type_entries[0]["style_slot"] = 17
	if not _expect_rejection(catalog, invalid_type_entries, "entry_0_style_slot_must_be_string", expected_ids):
		return
	var malformed_entry: Array = valid_entries.duplicate(true)
	malformed_entry[0] = "not_an_object"
	if not _expect_rejection(catalog, malformed_entry, "entry_0_must_be_object", expected_ids):
		return

	var substituted_entries: Array = valid_entries.duplicate(true)
	var original_display_name: String = substituted_entries[0]["display_name"]
	var original_description: String = substituted_entries[0]["short_description"]
	var original_icon_slot: String = substituted_entries[0]["icon_slot"]
	var original_style_slot: String = substituted_entries[0]["style_slot"]
	substituted_entries[0]["display_name"] = "Temporary Test Label"
	substituted_entries[0]["short_description"] = "Temporary test description."
	substituted_entries[0]["icon_slot"] = "test.resource.icon"
	substituted_entries[0]["style_slot"] = "test.resource.style"
	var reskinned_catalog := ResourceCatalog.new()
	if not reskinned_catalog.load_from_entries(substituted_entries):
		_fail("Presentation substitution failed validation")
		return
	var substituted_crumbs: ResourceDefinition = reskinned_catalog.get_definition("crumbs")
	if substituted_crumbs == null or substituted_crumbs.get_semantic_id() != "crumbs" or substituted_crumbs.get_display_name() != "Temporary Test Label" or _catalog_ids(reskinned_catalog) != expected_ids:
		_fail("Presentation substitution changed semantic identity, lookup, or order")
		return
	substituted_entries[0]["display_name"] = original_display_name
	substituted_entries[0]["short_description"] = original_description
	substituted_entries[0]["icon_slot"] = original_icon_slot
	substituted_entries[0]["style_slot"] = original_style_slot
	var restored_catalog := ResourceCatalog.new()
	if not restored_catalog.load_from_entries(substituted_entries) or restored_catalog.get_definition("crumbs").get_display_name() != original_display_name:
		_fail("Presentation metadata was not restored after substitution")
		return

	print("PHASE02_RESOURCE_CATALOG_SMOKE PASS")
	quit(0)


func _read_entries() -> Array:
	var file := FileAccess.open(RESOURCE_DATA_PATH, FileAccess.READ)
	if file == null:
		_fail("Could not read authoritative resource data")
		return []
	var parser := JSON.new()
	if parser.parse(file.get_as_text()) != OK or typeof(parser.data) != TYPE_ARRAY:
		_fail("Authoritative resource data was not valid JSON array data")
		return []
	return parser.data


func _catalog_ids(catalog: ResourceCatalog) -> Array[String]:
	var ids: Array[String] = []
	for definition: ResourceDefinition in catalog.get_ordered_definitions():
		ids.append(definition.get_semantic_id())
	return ids


func _expect_rejection(catalog: ResourceCatalog, entries: Array, expected_error: String, retained_ids: Array[String]) -> bool:
	if catalog.load_from_entries(entries):
		_fail("Malformed data was accepted: %s" % expected_error)
		return false
	if catalog.get_last_error() != expected_error:
		_fail("Unexpected validation result: %s" % catalog.get_last_error())
		return false
	if _catalog_ids(catalog) != retained_ids:
		_fail("Rejected data partially replaced the published catalog")
		return false
	return true


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
