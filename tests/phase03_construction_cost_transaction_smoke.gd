extends SceneTree

const RESOURCE_DATA_PATH := "res://data/resources/resource_definitions.json"
const BUILDING_DATA_PATH := "res://data/buildings/building_definitions.json"
const BASIC_NEST_COSTS := {"crumbs": 25, "twigs": 10}


func _initialize() -> void:
	var resources := ResourceCatalog.new()
	if not resources.load_from_file(RESOURCE_DATA_PATH):
		_fail("Resource prerequisite failed")
		return
	var buildings := BuildingCatalog.new()
	if not buildings.load_from_file(BUILDING_DATA_PATH, resources):
		_fail("Building prerequisite failed")
		return
	var nest: BuildingDefinition = buildings.get_definition("basic_nest")
	var authoritative_costs: Dictionary = nest.get_construction_costs()
	if authoritative_costs != BASIC_NEST_COSTS:
		_fail("Authoritative Basic Nest costs changed")
		return

	var ledger := _funded_ledger(resources, 75, 30, 7)
	var caller_before: Dictionary = authoritative_costs.duplicate(true)
	if ledger.debit_bundle(authoritative_costs) != ResourceLedger.BUNDLE_DEBIT_SUCCESS:
		_fail("Affordable authoritative bundle was rejected")
		return
	if ledger.get_balance_snapshot() != {"crumbs": 50, "twigs": 20, "shinies": 7}:
		_fail("Successful bundle did not apply the exact isolated debit")
		return
	if ledger.debit_bundle(authoritative_costs) != ResourceLedger.BUNDLE_DEBIT_SUCCESS:
		_fail("Affordable repeated bundle was rejected")
		return
	if ledger.get_balance_snapshot() != {"crumbs": 25, "twigs": 10, "shinies": 7}:
		_fail("Repeated bundle did not debit exactly once")
		return
	if ledger.debit_bundle(authoritative_costs) != ResourceLedger.BUNDLE_DEBIT_SUCCESS:
		_fail("Exactly affordable repeated bundle was rejected")
		return
	var depleted_snapshot: Dictionary = ledger.get_balance_snapshot()
	if ledger.debit_bundle(authoritative_costs) != ResourceLedger.BUNDLE_DEBIT_INSUFFICIENT_BALANCE or ledger.get_balance_snapshot() != depleted_snapshot:
		_fail("Rejected repeat changed ledger state")
		return
	if authoritative_costs != caller_before:
		_fail("Bundle debit mutated caller-owned costs")
		return

	for balances: Array in [[24, 10], [25, 9]]:
		for costs: Dictionary in [BASIC_NEST_COSTS, {"twigs": 10, "crumbs": 25}]:
			var insufficient := _funded_ledger(resources, balances[0], balances[1], 3)
			var before: Dictionary = insufficient.get_balance_snapshot()
			if insufficient.debit_bundle(costs) != ResourceLedger.BUNDLE_DEBIT_INSUFFICIENT_BALANCE or insufficient.get_balance_snapshot() != before:
				_fail("Insufficient bundle was not atomic across caller order")
				return

	var invalid_cases: Array = [
		[{}, ResourceLedger.BUNDLE_DEBIT_INVALID_BUNDLE],
		[{"": 1}, ResourceLedger.BUNDLE_DEBIT_INVALID_BUNDLE],
		[{7: 1}, ResourceLedger.BUNDLE_DEBIT_INVALID_BUNDLE],
		[{"crumbs": 0}, ResourceLedger.BUNDLE_DEBIT_INVALID_AMOUNT],
		[{"crumbs": -1}, ResourceLedger.BUNDLE_DEBIT_INVALID_AMOUNT],
		[{"crumbs": 1.0}, ResourceLedger.BUNDLE_DEBIT_INVALID_AMOUNT],
		[{"crumbs": "1"}, ResourceLedger.BUNDLE_DEBIT_INVALID_AMOUNT],
		[{"crumbs": true}, ResourceLedger.BUNDLE_DEBIT_INVALID_AMOUNT],
		[{"crumbs": []}, ResourceLedger.BUNDLE_DEBIT_INVALID_AMOUNT],
		[{"crumbs": {}}, ResourceLedger.BUNDLE_DEBIT_INVALID_AMOUNT],
		[{"crumbs": null}, ResourceLedger.BUNDLE_DEBIT_INVALID_AMOUNT],
		[{"crumbs": 1, "unknown": 1}, ResourceLedger.BUNDLE_DEBIT_UNKNOWN_RESOURCE],
		[{"unknown": 1, "crumbs": 1}, ResourceLedger.BUNDLE_DEBIT_UNKNOWN_RESOURCE],
	]
	for test_case: Array in invalid_cases:
		var rejected := _funded_ledger(resources, 100, 100, 100)
		var candidate: Dictionary = test_case[0]
		var candidate_before: Dictionary = candidate.duplicate(true)
		var snapshot: Dictionary = rejected.get_balance_snapshot()
		if rejected.debit_bundle(candidate) != test_case[1] or rejected.get_balance_snapshot() != snapshot or candidate != candidate_before:
			_fail("Malformed or unknown bundle rejection was unstable")
			return

	var returned_ids: Array[String] = ledger.get_ordered_ids()
	returned_ids.clear()
	var returned_snapshot: Dictionary = ledger.get_balance_snapshot()
	returned_snapshot["crumbs"] = 999
	if ledger.get_ordered_ids().is_empty() or ledger.get_balance("crumbs") != 0:
		_fail("Bundle operation weakened copied ledger queries")
		return

	var substituted_entries: Array = _read_building_entries()
	if substituted_entries.is_empty():
		return
	var substituted_entry: Dictionary = substituted_entries[0]
	substituted_entry["display_name"] = "Temporary Label"
	substituted_entry["description"] = "Temporary description"
	substituted_entry["icon_slot"] = "test.icon"
	substituted_entry["style_slot"] = "test.style"
	substituted_entry["world_visual_slot"] = "test.world"
	var substituted_catalog := BuildingCatalog.new()
	if not substituted_catalog.load_from_entries(substituted_entries, resources):
		_fail("Presentation-substituted building definition failed")
		return
	var substituted_costs: Dictionary = substituted_catalog.get_definition("basic_nest").get_construction_costs()
	var substituted_ledger := _funded_ledger(resources, 25, 10, 4)
	if substituted_ledger.debit_bundle(substituted_costs) != ResourceLedger.BUNDLE_DEBIT_SUCCESS or substituted_ledger.get_balance_snapshot() != {"crumbs": 0, "twigs": 0, "shinies": 4}:
		_fail("Presentation substitution changed transaction mechanics")
		return

	print("PHASE03_CONSTRUCTION_COST_TRANSACTION_SMOKE PASS")
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