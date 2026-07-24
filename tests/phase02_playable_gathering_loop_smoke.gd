extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const RESOURCE_PATH := "res://data/resources/resource_definitions.json"
const ACTION_PATH := "res://data/resources/gathering_action_definitions.json"
const EXPECTED_ACTION_IDS: Array[String] = ["gather_crumbs", "gather_twigs", "gather_shinies"]
const EXPECTED_RESOURCE_IDS: Array[String] = ["crumbs", "twigs", "shinies"]


func _initialize() -> void:
	var catalogs: Array = _load_catalogs(false)
	if catalogs.is_empty():
		return
	var main := MAIN_SCENE.instantiate() as MainRuntime
	if main == null:
		_fail("Main scene did not instantiate as MainRuntime")
		return
	if main.get_node_or_null("RooftopGrid") == null or main.get_node_or_null("WorldObjects") == null or main.get_node_or_null("RooftopCamera") == null:
		_fail("Main scene no longer preserves rooftop world and camera nodes")
		return
	if not main.setup_runtime(catalogs[0], catalogs[1]):
		_fail("Runtime rejected valid catalogs")
		return
	if not _verify_initial_ui(main, false):
		return
	var panel := main.get_node("RuntimeUi/Interface/GatheringPanel") as GatheringPanel
	var hud := main.get_node("RuntimeUi/Interface/ResourceHud") as ResourceHud
	var ledger: ResourceLedger = main.get_runtime_ledger()
	for index: int in EXPECTED_ACTION_IDS.size():
		var before: Dictionary = ledger.get_balance_snapshot()
		if not panel.request_action(EXPECTED_ACTION_IDS[index]):
			_fail("Panel rejected authoritative action request")
			return
		if not _expect_single_credit(before, ledger.get_balance_snapshot(), EXPECTED_RESOURCE_IDS[index], 1):
			return
	if not _expect_balances(hud, ledger, [1, 1, 1]):
		return
	if not panel.request_action("gather_crumbs") or not panel.request_action("gather_crumbs"):
		_fail("Repeated action request failed")
		return
	if not _expect_balances(hud, ledger, [3, 1, 1]):
		return

	var stable_snapshot: Dictionary = ledger.get_balance_snapshot()
	var stable_controls: Array[GatheringActionButton] = panel.get_ordered_controls()
	if panel.request_action("") or panel.request_action("unknown_action"):
		_fail("Panel accepted empty or unknown semantic action ID")
		return
	var rejected := main.request_gathering_action("unknown_action")
	if rejected.succeeded() or ledger.get_balance_snapshot() != stable_snapshot:
		_fail("Rejected action mutated the ledger")
		return
	if main.setup_runtime(null, catalogs[1]) or main.setup_runtime(catalogs[0], null):
		_fail("Runtime accepted invalid dependencies")
		return
	if ledger.get_balance_snapshot() != stable_snapshot or panel.get_ordered_controls() != stable_controls or not _expect_balances(hud, ledger, [3, 1, 1]):
		_fail("Rejected setup replaced last valid runtime/UI state")
		return

	var substituted: Array = _load_catalogs(true)
	if substituted.is_empty():
		return
	var reskinned_main := MAIN_SCENE.instantiate() as MainRuntime
	if not reskinned_main.setup_runtime(substituted[0], substituted[1]) or not _verify_initial_ui(reskinned_main, true):
		_fail("Equivalent presentation substitution changed setup")
		return
	var reskinned_panel := reskinned_main.get_node("RuntimeUi/Interface/GatheringPanel") as GatheringPanel
	var reskinned_hud := reskinned_main.get_node("RuntimeUi/Interface/ResourceHud") as ResourceHud
	var reskinned_ledger: ResourceLedger = reskinned_main.get_runtime_ledger()
	for action_id: String in EXPECTED_ACTION_IDS:
		if not reskinned_panel.request_action(action_id):
			_fail("Reskinned panel rejected semantic action")
			return
	if reskinned_ledger.get_balance_snapshot() != {"crumbs": 1, "twigs": 1, "shinies": 1} or not _expect_balances(reskinned_hud, reskinned_ledger, [1, 1, 1]):
		_fail("Presentation substitution changed mechanics or balances")
		return
	main.free()
	reskinned_main.free()
	print("PHASE02_PLAYABLE_GATHERING_LOOP_SMOKE PASS")
	quit(0)


func _verify_initial_ui(main: MainRuntime, substituted: bool) -> bool:
	if not main.is_runtime_ready():
		_fail("Runtime did not publish ready state")
		return false
	var panel := main.get_node("RuntimeUi/Interface/GatheringPanel") as GatheringPanel
	var hud := main.get_node("RuntimeUi/Interface/ResourceHud") as ResourceHud
	var controls: Array[GatheringActionButton] = panel.get_ordered_controls()
	if controls.size() != 3 or hud.get_ordered_rows().size() != 3:
		_fail("Runtime did not create exactly three action controls and resource rows")
		return false
	for index: int in EXPECTED_ACTION_IDS.size():
		var control: GatheringActionButton = controls[index]
		if control.get_action_id() != EXPECTED_ACTION_IDS[index] or panel.get_control(EXPECTED_ACTION_IDS[index]) != control:
			_fail("Action order, semantic binding, or lookup changed")
			return false
		if control.text.is_empty():
			_fail("Action control lost readable non-color identity")
			return false
		if substituted and (control.text != "Temporary Action %d" % index or control.get_icon_slot() != "test.action.icon.%d" % index or control.get_style_slot() != "test.action.style.%d" % index):
			_fail("Action presentation metadata substitution was not rendered")
			return false
		var row: ResourceHudRow = hud.get_ordered_rows()[index]
		if substituted and (row.get_display_name() != "Temporary Resource %d" % index or row.get_icon_slot() != "test.resource.icon.%d" % index or row.get_style_slot() != "test.resource.style.%d" % index):
			_fail("Resource presentation metadata substitution was not rendered")
			return false
	return true


func _expect_single_credit(before: Dictionary, after: Dictionary, resource_id: String, amount: int) -> bool:
	for id: String in EXPECTED_RESOURCE_IDS:
		var expected: int = int(before[id]) + (amount if id == resource_id else 0)
		if int(after[id]) != expected:
			_fail("Action did not perform exactly one isolated catalog credit")
			return false
	return true


func _expect_balances(hud: ResourceHud, ledger: ResourceLedger, expected: Array) -> bool:
	var before: Dictionary = ledger.get_balance_snapshot()
	if not hud.refresh() or ledger.get_balance_snapshot() != before:
		_fail("HUD refresh mutated ledger state")
		return false
	for index: int in EXPECTED_RESOURCE_IDS.size():
		if ledger.get_balance(EXPECTED_RESOURCE_IDS[index]) != int(expected[index]) or hud.get_row(EXPECTED_RESOURCE_IDS[index]).get_displayed_balance() != int(expected[index]):
			_fail("HUD balance did not match exact ledger balance")
			return false
	return true


func _load_catalogs(substitute_presentation: bool) -> Array:
	var resource_entries: Array = _read_array(RESOURCE_PATH)
	var action_entries: Array = _read_array(ACTION_PATH)
	if resource_entries.is_empty() or action_entries.is_empty():
		return []
	if substitute_presentation:
		for index: int in resource_entries.size():
			var resource_entry: Dictionary = resource_entries[index]
			resource_entry["display_name"] = "Temporary Resource %d" % index
			resource_entry["short_description"] = "Temporary resource description %d" % index
			resource_entry["icon_slot"] = "test.resource.icon.%d" % index
			resource_entry["style_slot"] = "test.resource.style.%d" % index
		for index: int in action_entries.size():
			var action_entry: Dictionary = action_entries[index]
			action_entry["display_name"] = "Temporary Action %d" % index
			action_entry["short_description"] = "Temporary action description %d" % index
			action_entry["icon_slot"] = "test.action.icon.%d" % index
			action_entry["style_slot"] = "test.action.style.%d" % index
	var resources := ResourceCatalog.new()
	if not resources.load_from_entries(resource_entries):
		_fail("Resource catalog setup failed: %s" % resources.get_last_error())
		return []
	var actions := GatheringActionCatalog.new()
	if not actions.load_from_entries(action_entries, resources):
		_fail("Action catalog setup failed: %s" % actions.get_last_error())
		return []
	return [resources, actions]


func _read_array(path: String) -> Array:
	var file := FileAccess.open(path, FileAccess.READ)
	var parser := JSON.new()
	if file == null or parser.parse(file.get_as_text()) != OK or typeof(parser.data) != TYPE_ARRAY:
		_fail("Could not read valid catalog array: %s" % path)
		return []
	return parser.data


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
