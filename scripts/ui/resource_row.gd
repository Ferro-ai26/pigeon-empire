class_name ResourceHudRow
extends HBoxContainer

@export_group("Editor-visible presentation bindings")
@export var marker_path: NodePath = ^"IconFallback"
@export var name_label_path: NodePath = ^"DisplayName"
@export var balance_label_path: NodePath = ^"Balance"

var _semantic_id: String = ""
var _icon_slot: String = ""
var _style_slot: String = ""


func bind_definition(definition: ResourceDefinition) -> bool:
	if definition == null or definition.get_semantic_id().is_empty():
		return false
	var name_label := get_node_or_null(name_label_path) as Label
	var marker := get_node_or_null(marker_path) as Control
	var balance_label := get_node_or_null(balance_label_path) as Label
	if name_label == null or marker == null or balance_label == null:
		return false
	_semantic_id = definition.get_semantic_id()
	_icon_slot = definition.get_icon_slot()
	_style_slot = definition.get_style_slot()
	name_label.text = definition.get_display_name()
	marker.tooltip_text = _icon_slot
	tooltip_text = _style_slot
	return true


func set_displayed_balance(value: int) -> bool:
	if value < 0:
		return false
	var balance_label := get_node_or_null(balance_label_path) as Label
	if balance_label == null:
		return false
	balance_label.text = str(value)
	return true


func get_semantic_id() -> String:
	return _semantic_id


func get_display_name() -> String:
	var name_label := get_node_or_null(name_label_path) as Label
	return name_label.text if name_label != null else ""


func get_displayed_balance() -> int:
	var balance_label := get_node_or_null(balance_label_path) as Label
	if balance_label == null or not balance_label.text.is_valid_int():
		return ResourceLedger.UNKNOWN_BALANCE
	return balance_label.text.to_int()


func get_icon_slot() -> String:
	return _icon_slot


func get_style_slot() -> String:
	return _style_slot
