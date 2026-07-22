extends SceneTree

const ACTION_DATA_PATH := "res://data/resources/gathering_action_definitions.json"
const RESOURCE_DATA_PATH := "res://data/resources/resource_definitions.json"
const EXPECTED_ACTION_IDS: Array[String] = ["gather_crumbs", "gather_twigs", "gather_shinies"]
const EXPECTED_RESOURCE_IDS: Array[String] = ["crumbs", "twigs", "shinies"]


func _initialize() -> void:
	var resources := ResourceCatalog.new()
	if not resources.load_from_file(RESOURCE_DATA_PATH):
		_fail("Authoritative resource catalog failed: %s" % resources.get_last_error())
		return
	var actions := GatheringActionCatalog.new()
	if not actions.load_from_file(ACTION_DATA_PATH, resources):
		_fail("Authoritative action catalog failed: %s" % actions.get_last_error())
		return
	var ledger := ResourceLedger.new(resources)
	var executor := GatheringActionExecutor.new(actions, ledger)
	var original_order: Array[String] = actions.get_ordered_ids()
	var original_mechanics: Dictionary = _mechanics_snapshot(actions)

	for index: int in EXPECTED_ACTION_IDS.size():
		var action_id: String = EXPECTED_ACTION_IDS[index]
		var definition: GatheringActionDefinition = actions.get_definition(action_id)
		var before: Dictionary = ledger.get_balance_snapshot()
		var result: GatheringActionExecutor.ExecutionResult = executor.execute(action_id)
		if not result.succeeded() or result.status != GatheringActionExecutor.STATUS_SUCCESS:
			_fail("Starter action failed: %s" % action_id)
			return
		if result.action_id != action_id or result.resource_id != definition.get_resource_id() or result.reward_amount != definition.get_reward_amount():
			_fail("Execution result did not report exact semantic mechanics")
			return
		if not _has_exact_delta(before, ledger.get_balance_snapshot(), result.resource_id, result.reward_amount):
			_fail("Starter action did not apply exactly one isolated credit")
			return

	var repeated_id: String = EXPECTED_ACTION_IDS[0]
	var repeated_definition: GatheringActionDefinition = actions.get_definition(repeated_id)
	var repeated_before: int = ledger.get_balance(repeated_definition.get_resource_id())
	for unused: int in 3:
		if not executor.execute(repeated_id).succeeded():
			_fail("Repeated execution failed")
			return
	if ledger.get_balance(repeated_definition.get_resource_id()) != repeated_before + repeated_definition.get_reward_amount() * 3:
		_fail("Repeated execution did not accumulate deterministically")
		return

	var stable_snapshot: Dictionary = ledger.get_balance_snapshot()
	var invalid_cases: Array[Dictionary] = [
		{"id": "", "status": GatheringActionExecutor.STATUS_EMPTY_ACTION_ID},
		{"id": "   ", "status": GatheringActionExecutor.STATUS_EMPTY_ACTION_ID},
		{"id": "unknown_action", "status": GatheringActionExecutor.STATUS_UNKNOWN_ACTION_ID},
	]
	for invalid_case: Dictionary in invalid_cases:
		var invalid_result: GatheringActionExecutor.ExecutionResult = executor.execute(invalid_case["id"])
		if invalid_result.succeeded() or invalid_result.status != invalid_case["status"] or ledger.get_balance_snapshot() != stable_snapshot:
			_fail("Invalid action handling was unstable or mutated the ledger")
			return

	var no_catalog := GatheringActionExecutor.new(null, ledger)
	if no_catalog.execute("gather_crumbs").status != GatheringActionExecutor.STATUS_MISSING_CATALOG or ledger.get_balance_snapshot() != stable_snapshot:
		_fail("Missing catalog dependency was not rejected without mutation")
		return
	var no_ledger := GatheringActionExecutor.new(actions, null)
	if no_ledger.execute("gather_crumbs").status != GatheringActionExecutor.STATUS_MISSING_LEDGER or ledger.get_balance_snapshot() != stable_snapshot:
		_fail("Missing ledger dependency was not rejected without external mutation")
		return

	if actions.get_ordered_ids() != original_order or _mechanics_snapshot(actions) != original_mechanics:
		_fail("Execution mutated gathering catalog identity, order, or mechanics")
		return

	var substituted_entries: Array = _read_action_entries()
	if substituted_entries.is_empty():
		return
	for index: int in substituted_entries.size():
		substituted_entries[index]["display_name"] = "Replacement Label %d" % index
		substituted_entries[index]["short_description"] = "Replacement copy %d" % index
		substituted_entries[index]["icon_slot"] = "replacement.action.%d.icon" % index
		substituted_entries[index]["style_slot"] = "replacement.action.%d.style" % index
	var substituted_actions := GatheringActionCatalog.new()
	if not substituted_actions.load_from_entries(substituted_entries, resources):
		_fail("Presentation-substituted action catalog failed validation")
		return
	var substituted_ledger := ResourceLedger.new(resources)
	var substituted_executor := GatheringActionExecutor.new(substituted_actions, substituted_ledger)
	for action_id: String in EXPECTED_ACTION_IDS:
		var result: GatheringActionExecutor.ExecutionResult = substituted_executor.execute(action_id)
		if not result.succeeded():
			_fail("Presentation substitution changed execution success")
			return
	if substituted_ledger.get_balance_snapshot() != {"crumbs": 1, "twigs": 1, "shinies": 1} or _mechanics_snapshot(substituted_actions) != original_mechanics:
		_fail("Presentation substitution changed mechanics or ledger deltas")
		return

	print("PHASE02_GATHERING_ACTION_EXECUTOR_SMOKE PASS")
	quit(0)


func _has_exact_delta(before: Dictionary, after: Dictionary, changed_id: String, amount: int) -> bool:
	if before.keys() != after.keys():
		return false
	for resource_id: String in EXPECTED_RESOURCE_IDS:
		var expected: int = int(before[resource_id]) + (amount if resource_id == changed_id else 0)
		if int(after[resource_id]) != expected:
			return false
	return true


func _mechanics_snapshot(catalog: GatheringActionCatalog) -> Dictionary:
	var snapshot: Dictionary = {}
	for definition: GatheringActionDefinition in catalog.get_ordered_definitions():
		snapshot[definition.get_action_id()] = [definition.get_resource_id(), definition.get_reward_amount()]
	return snapshot


func _read_action_entries() -> Array:
	var file := FileAccess.open(ACTION_DATA_PATH, FileAccess.READ)
	if file == null:
		_fail("Could not read authoritative action data")
		return []
	var parser := JSON.new()
	if parser.parse(file.get_as_text()) != OK or typeof(parser.data) != TYPE_ARRAY:
		_fail("Authoritative action data was not a JSON array")
		return []
	return parser.data


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
