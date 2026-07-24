class_name MainRuntime
extends Node2D

const RESOURCE_DATA_PATH := "res://data/resources/resource_definitions.json"
const ACTION_DATA_PATH := "res://data/resources/gathering_action_definitions.json"

@export_group("Runtime UI bindings")
@export var resource_hud_path: NodePath = ^"RuntimeUi/Interface/ResourceHud"
@export var gathering_panel_path: NodePath = ^"RuntimeUi/Interface/GatheringPanel"

var _resource_catalog: ResourceCatalog
var _action_catalog: GatheringActionCatalog
var _ledger: ResourceLedger
var _executor: GatheringActionExecutor
var _setup_complete: bool = false


func _ready() -> void:
	setup_runtime_from_files()
	print("PIGEON_EMPIRE_STARTUP_OK")
	if DisplayServer.get_name() == "headless":
		get_tree().quit()


func setup_runtime_from_files() -> bool:
	var resource_catalog := ResourceCatalog.new()
	if not resource_catalog.load_from_file(RESOURCE_DATA_PATH):
		return false
	var action_catalog := GatheringActionCatalog.new()
	if not action_catalog.load_from_file(ACTION_DATA_PATH, resource_catalog):
		return false
	return setup_runtime(resource_catalog, action_catalog)


func setup_runtime(resource_catalog: ResourceCatalog, action_catalog: GatheringActionCatalog) -> bool:
	if resource_catalog == null or action_catalog == null or resource_catalog.size() <= 0 or action_catalog.size() <= 0:
		return false
	var hud := get_node_or_null(resource_hud_path) as ResourceHud
	var panel := get_node_or_null(gathering_panel_path) as GatheringPanel
	if hud == null or panel == null:
		return false
	var candidate_ledger := ResourceLedger.new(resource_catalog)
	var candidate_executor := GatheringActionExecutor.new(action_catalog, candidate_ledger)
	if not hud.setup(resource_catalog, candidate_ledger):
		return false
	if not panel.setup(action_catalog):
		return false
	_resource_catalog = resource_catalog
	_action_catalog = action_catalog
	_ledger = candidate_ledger
	_executor = candidate_executor
	_setup_complete = true
	return true


func request_gathering_action(action_id: String) -> GatheringActionExecutor.ExecutionResult:
	if not _setup_complete or _executor == null:
		return GatheringActionExecutor.ExecutionResult.new(GatheringActionExecutor.STATUS_MISSING_CATALOG, action_id)
	var before: Dictionary = _ledger.get_balance_snapshot()
	var result: GatheringActionExecutor.ExecutionResult = _executor.execute(action_id)
	if not result.succeeded():
		return result
	var hud := get_node_or_null(resource_hud_path) as ResourceHud
	if hud == null or not hud.refresh():
		# This cannot roll back a successful executor credit; setup guarantees the HUD dependency.
		push_error("runtime_hud_refresh_failed_after_credit")
		return result
	if before == _ledger.get_balance_snapshot():
		push_error("runtime_action_reported_success_without_mutation")
	return result


func get_runtime_ledger() -> ResourceLedger:
	return _ledger


func is_runtime_ready() -> bool:
	return _setup_complete


func _on_gathering_panel_action_requested(action_id: String) -> void:
	request_gathering_action(action_id)
