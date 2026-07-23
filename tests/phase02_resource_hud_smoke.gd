extends SceneTree

const RESOURCE_DATA_PATH := "res://data/resources/resource_definitions.json"
const HUD_SCENE := preload("res://scenes/ui/resource_hud.tscn")
const EXPECTED_IDS: Array[String] = ["crumbs", "twigs", "shinies"]


func _initialize() -> void:
	var catalog := ResourceCatalog.new()
	if not catalog.load_from_file(RESOURCE_DATA_PATH):
		_fail("Authoritative catalog failed: %s" % catalog.get_last_error())
		return
	var ledger := ResourceLedger.new(catalog)
	var hud := HUD_SCENE.instantiate() as ResourceHud
	if hud == null:
		_fail("HUD scene did not instantiate as ResourceHud")
		return
	root.add_child(hud)
	if not hud.setup(catalog, ledger):
		_fail("HUD rejected valid catalog and ledger dependencies")
		return
	if not _expect_rows(hud, EXPECTED_IDS, [0, 0, 0]):
		return
	var catalog_snapshot := _catalog_snapshot(catalog)
	var before_refresh: Dictionary = ledger.get_balance_snapshot()
	if not hud.refresh() or ledger.get_balance_snapshot() != before_refresh or _catalog_snapshot(catalog) != catalog_snapshot:
		_fail("Refresh mutated authoritative state")
		return
	if not ledger.credit("crumbs", 7) or not ledger.credit("shinies", 3):
		_fail("Test setup could not credit the ledger")
		return
	if not hud.refresh() or not _expect_rows(hud, EXPECTED_IDS, [7, 0, 3]):
		return

	var stable_ledger: Dictionary = ledger.get_balance_snapshot()
	if hud.setup(null, ledger) or hud.setup(catalog, null):
		_fail("HUD accepted null dependencies")
		return
	var foreign_entries: Array = _read_entries()
	if foreign_entries.is_empty():
		return
	foreign_entries.remove_at(foreign_entries.size() - 1)
	var foreign_catalog := ResourceCatalog.new()
	if not foreign_catalog.load_from_entries(foreign_entries):
		_fail("Could not construct deterministic mismatched catalog")
		return
	if hud.setup(foreign_catalog, ledger) or ledger.get_balance_snapshot() != stable_ledger:
		_fail("Invalid dependency setup mutated the supplied ledger")
		return
	if not _expect_rows(hud, EXPECTED_IDS, [7, 0, 3]):
		_fail("Rejected setup replaced the last valid HUD rows")
		return

	var substituted_entries: Array = _read_entries()
	if substituted_entries.is_empty():
		return
	for index: int in substituted_entries.size():
		var entry: Dictionary = substituted_entries[index]
		entry["display_name"] = "Temporary HUD Label %d" % index
		entry["short_description"] = "Temporary substituted HUD description %d." % index
		entry["icon_slot"] = "test.hud.icon.%d" % index
		entry["style_slot"] = "test.hud.style.%d" % index
	var substituted_catalog := ResourceCatalog.new()
	if not substituted_catalog.load_from_entries(substituted_entries):
		_fail("Substituted presentation catalog failed validation")
		return
	var substituted_ledger := ResourceLedger.new(substituted_catalog)
	if not substituted_ledger.credit("crumbs", 7) or not substituted_ledger.credit("shinies", 3):
		_fail("Could not mirror balances in substituted ledger")
		return
	var substituted_hud := HUD_SCENE.instantiate() as ResourceHud
	root.add_child(substituted_hud)
	if not substituted_hud.setup(substituted_catalog, substituted_ledger):
		_fail("HUD rejected equivalent substituted presentation metadata")
		return
	if not _expect_rows(substituted_hud, EXPECTED_IDS, [7, 0, 3]):
		return
	for index: int in EXPECTED_IDS.size():
		var row: ResourceHudRow = substituted_hud.get_ordered_rows()[index]
		if row.get_display_name() != "Temporary HUD Label %d" % index or row.get_icon_slot() != "test.hud.icon.%d" % index or row.get_style_slot() != "test.hud.style.%d" % index:
			_fail("HUD did not render substituted presentation metadata")
			return
	var substituted_snapshot: Dictionary = substituted_ledger.get_balance_snapshot()
	if not substituted_hud.refresh() or substituted_ledger.get_balance_snapshot() != substituted_snapshot:
		_fail("Reskin substitution changed balance behavior")
		return

	print("PHASE02_RESOURCE_HUD_SMOKE PASS")
	quit(0)


func _expect_rows(hud: ResourceHud, expected_ids: Array[String], expected_balances: Array) -> bool:
	var rows: Array[ResourceHudRow] = hud.get_ordered_rows()
	if rows.size() != expected_ids.size():
		_fail("HUD did not create exactly one row per catalog definition")
		return false
	for index: int in expected_ids.size():
		if rows[index].get_semantic_id() != expected_ids[index]:
			_fail("HUD row order or semantic identity changed")
			return false
		if rows[index].get_displayed_balance() != int(expected_balances[index]):
			_fail("HUD displayed balance did not match the ledger")
			return false
		if hud.get_row(expected_ids[index]) != rows[index]:
			_fail("Semantic row lookup did not resolve the ordered row")
			return false
	return true


func _catalog_snapshot(catalog: ResourceCatalog) -> Array[Dictionary]:
	var snapshot: Array[Dictionary] = []
	for definition: ResourceDefinition in catalog.get_ordered_definitions():
		snapshot.append({
			"id": definition.get_semantic_id(),
			"display_name": definition.get_display_name(),
			"short_description": definition.get_short_description(),
			"icon_slot": definition.get_icon_slot(),
			"style_slot": definition.get_style_slot(),
		})
	return snapshot


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


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
