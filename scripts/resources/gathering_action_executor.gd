class_name GatheringActionExecutor
extends RefCounted

const STATUS_SUCCESS: StringName = &"success"
const STATUS_EMPTY_ACTION_ID: StringName = &"empty_action_id"
const STATUS_UNKNOWN_ACTION_ID: StringName = &"unknown_action_id"
const STATUS_MISSING_CATALOG: StringName = &"missing_catalog"
const STATUS_MISSING_LEDGER: StringName = &"missing_ledger"
const STATUS_LEDGER_CREDIT_FAILED: StringName = &"ledger_credit_failed"


class ExecutionResult extends RefCounted:
	var status: StringName
	var action_id: String
	var resource_id: String
	var reward_amount: int

	func _init(
		result_status: StringName,
		result_action_id: String = "",
		result_resource_id: String = "",
		result_reward_amount: int = 0
	) -> void:
		status = result_status
		action_id = result_action_id
		resource_id = result_resource_id
		reward_amount = result_reward_amount

	func succeeded() -> bool:
		return status == GatheringActionExecutor.STATUS_SUCCESS


var _catalog: GatheringActionCatalog
var _ledger: ResourceLedger


func _init(catalog: GatheringActionCatalog, ledger: ResourceLedger) -> void:
	_catalog = catalog
	_ledger = ledger


func execute(action_id: String) -> ExecutionResult:
	if _catalog == null:
		return ExecutionResult.new(STATUS_MISSING_CATALOG, action_id)
	if _ledger == null:
		return ExecutionResult.new(STATUS_MISSING_LEDGER, action_id)
	if action_id.strip_edges().is_empty():
		return ExecutionResult.new(STATUS_EMPTY_ACTION_ID, action_id)
	var definition: GatheringActionDefinition = _catalog.get_definition(action_id)
	if definition == null:
		return ExecutionResult.new(STATUS_UNKNOWN_ACTION_ID, action_id)
	var resource_id: String = definition.get_resource_id()
	var reward_amount: int = definition.get_reward_amount()
	if not _ledger.credit(resource_id, reward_amount):
		return ExecutionResult.new(STATUS_LEDGER_CREDIT_FAILED, action_id, resource_id, reward_amount)
	return ExecutionResult.new(STATUS_SUCCESS, action_id, resource_id, reward_amount)
