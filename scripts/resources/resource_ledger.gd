class_name ResourceLedger
extends RefCounted

## Deterministic query result for an ID that is not present in the ledger.
## Valid balances are always zero or greater.
const UNKNOWN_BALANCE: int = -1

## Stable, presentation-neutral outcomes for atomic bundle debits.
const BUNDLE_DEBIT_SUCCESS: StringName = &"success"
const BUNDLE_DEBIT_INVALID_BUNDLE: StringName = &"invalid_bundle"
const BUNDLE_DEBIT_UNKNOWN_RESOURCE: StringName = &"unknown_resource"
const BUNDLE_DEBIT_INVALID_AMOUNT: StringName = &"invalid_amount"
const BUNDLE_DEBIT_INSUFFICIENT_BALANCE: StringName = &"insufficient_balance"

var _ordered_ids: Array[String] = []
var _balances: Dictionary = {}


func _init(catalog: ResourceCatalog) -> void:
	if catalog == null:
		return
	for definition: ResourceDefinition in catalog.get_ordered_definitions():
		var semantic_id: String = definition.get_semantic_id()
		_ordered_ids.append(semantic_id)
		_balances[semantic_id] = 0


func has_resource(semantic_id: String) -> bool:
	return _balances.has(semantic_id)


func get_balance(semantic_id: String) -> int:
	if not has_resource(semantic_id):
		return UNKNOWN_BALANCE
	return int(_balances[semantic_id])


func credit(semantic_id: String, amount: int) -> bool:
	if not has_resource(semantic_id) or amount <= 0:
		return false
	_balances[semantic_id] = get_balance(semantic_id) + amount
	return true


func can_afford(semantic_id: String, amount: int) -> bool:
	return has_resource(semantic_id) and amount > 0 and get_balance(semantic_id) >= amount


func debit(semantic_id: String, amount: int) -> bool:
	if not can_afford(semantic_id, amount):
		return false
	_balances[semantic_id] = get_balance(semantic_id) - amount
	return true


## Debits a complete semantic resource-cost bundle as one all-or-nothing operation.
## The caller-owned dictionary is read only; every entry is validated before mutation.
func debit_bundle(costs: Dictionary) -> StringName:
	if costs.is_empty():
		return BUNDLE_DEBIT_INVALID_BUNDLE
	for semantic_id_variant: Variant in costs:
		if typeof(semantic_id_variant) != TYPE_STRING or String(semantic_id_variant).is_empty():
			return BUNDLE_DEBIT_INVALID_BUNDLE
	for amount_variant: Variant in costs.values():
		if typeof(amount_variant) != TYPE_INT or int(amount_variant) <= 0:
			return BUNDLE_DEBIT_INVALID_AMOUNT
	for semantic_id_variant: Variant in costs:
		var semantic_id: String = semantic_id_variant
		if not has_resource(semantic_id):
			return BUNDLE_DEBIT_UNKNOWN_RESOURCE
	for semantic_id_variant: Variant in costs:
		var semantic_id: String = semantic_id_variant
		var amount: int = costs[semantic_id]
		if get_balance(semantic_id) < amount:
			return BUNDLE_DEBIT_INSUFFICIENT_BALANCE
	for semantic_id_variant: Variant in costs:
		var semantic_id: String = semantic_id_variant
		var amount: int = costs[semantic_id]
		_balances[semantic_id] = get_balance(semantic_id) - amount
	return BUNDLE_DEBIT_SUCCESS


func get_ordered_ids() -> Array[String]:
	return _ordered_ids.duplicate()


func get_balance_snapshot() -> Dictionary:
	return _balances.duplicate()
