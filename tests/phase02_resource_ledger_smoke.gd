extends SceneTree

const RESOURCE_DATA_PATH := "res://data/resources/resource_definitions.json"
const EXPECTED_IDS: Array[String] = ["crumbs", "twigs", "shinies"]


func _initialize() -> void:
	var catalog := ResourceCatalog.new()
	if not catalog.load_from_file(RESOURCE_DATA_PATH):
		_fail("Authoritative catalog failed: %s" % catalog.get_last_error())
		return
	var ledger := ResourceLedger.new(catalog)
	if ledger.get_ordered_ids() != EXPECTED_IDS:
		_fail("Ledger membership did not preserve catalog order")
		return
	for semantic_id: String in EXPECTED_IDS:
		if not ledger.has_resource(semantic_id) or ledger.get_balance(semantic_id) != 0:
			_fail("Ledger did not initialize every known counter to integer zero")
			return

	if ledger.has_resource("unknown") or ledger.get_balance("unknown") != ResourceLedger.UNKNOWN_BALANCE:
		_fail("Unknown query did not return the documented non-mutating result")
		return
	if ledger.get_ordered_ids() != EXPECTED_IDS:
		_fail("Unknown query created a counter")
		return

	if not ledger.credit("crumbs", 10) or ledger.get_balance("crumbs") != 10:
		_fail("Valid credit did not update the addressed counter")
		return
	if ledger.get_balance("twigs") != 0 or ledger.get_balance("shinies") != 0:
		_fail("Credit changed an independent counter")
		return
	if not ledger.can_afford("crumbs", 10) or not ledger.can_afford("crumbs", 4):
		_fail("Affordability rejected a valid positive affordable amount")
		return
	if ledger.can_afford("crumbs", 11) or ledger.can_afford("crumbs", 0) or ledger.can_afford("crumbs", -1) or ledger.can_afford("unknown", 1):
		_fail("Affordability accepted an invalid or insufficient request")
		return
	if not ledger.debit("crumbs", 4) or ledger.get_balance("crumbs") != 6:
		_fail("Valid debit did not subtract the exact amount")
		return

	var stable_snapshot: Dictionary = ledger.get_balance_snapshot()
	if ledger.credit("unknown", 3) or ledger.credit("twigs", 0) or ledger.credit("twigs", -3):
		_fail("Invalid credit was accepted")
		return
	if ledger.debit("unknown", 1) or ledger.debit("crumbs", 0) or ledger.debit("crumbs", -2) or ledger.debit("crumbs", 7):
		_fail("Invalid or insufficient debit was accepted")
		return
	if ledger.get_balance_snapshot() != stable_snapshot:
		_fail("Rejected mutation changed ledger state")
		return

	var returned_ids: Array[String] = ledger.get_ordered_ids()
	returned_ids.clear()
	var returned_balances: Dictionary = ledger.get_balance_snapshot()
	returned_balances["crumbs"] = -99
	returned_balances["intruder"] = 50
	if ledger.get_ordered_ids() != EXPECTED_IDS or ledger.get_balance("crumbs") != 6 or ledger.has_resource("intruder"):
		_fail("Returned collection exposed mutable ledger storage")
		return

	var substituted_entries: Array = _read_entries()
	if substituted_entries.is_empty():
		return
	for index: int in substituted_entries.size():
		var entry: Dictionary = substituted_entries[index]
		entry["display_name"] = "Temporary Label %d" % index
		entry["short_description"] = "Temporary substituted presentation metadata."
		entry["icon_slot"] = "test.resource.%d.icon" % index
		entry["style_slot"] = "test.resource.%d.style" % index
	var substituted_catalog := ResourceCatalog.new()
	if not substituted_catalog.load_from_entries(substituted_entries):
		_fail("Substituted presentation catalog failed validation")
		return
	var substituted_ledger := ResourceLedger.new(substituted_catalog)
	if substituted_ledger.get_ordered_ids() != EXPECTED_IDS:
		_fail("Presentation substitution changed ledger identity or order")
		return
	if not substituted_ledger.credit("shinies", 8) or not substituted_ledger.debit("shinies", 3) or substituted_ledger.get_balance("shinies") != 5:
		_fail("Presentation substitution changed ledger mutation behavior")
		return
	for semantic_id: String in ["crumbs", "twigs"]:
		if substituted_ledger.get_balance(semantic_id) != 0:
			_fail("Presentation substitution changed independent initial balances")
			return

	print("PHASE02_RESOURCE_LEDGER_SMOKE PASS")
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


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
