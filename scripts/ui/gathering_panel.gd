class_name GatheringPanel
extends PanelContainer

signal action_requested(action_id: String)

@export_group("Reusable presentation components")
@export var action_button_scene: PackedScene
@export var actions_container_path: NodePath = ^"Margin/Actions"

var _catalog: GatheringActionCatalog
var _ordered_controls: Array[GatheringActionButton] = []
var _controls_by_id: Dictionary = {}


func setup(catalog: GatheringActionCatalog) -> bool:
	if catalog == null or catalog.size() <= 0 or action_button_scene == null:
		return false
	var actions_container := get_node_or_null(actions_container_path) as Container
	if actions_container == null:
		return false
	var candidates: Array[GatheringActionButton] = []
	for definition: GatheringActionDefinition in catalog.get_ordered_definitions():
		var control := action_button_scene.instantiate() as GatheringActionButton
		if control == null or not control.bind_definition(definition):
			for candidate: GatheringActionButton in candidates:
				candidate.free()
			return false
		control.pressed.connect(_on_control_pressed.bind(control))
		candidates.append(control)
	for child: Node in actions_container.get_children():
		actions_container.remove_child(child)
		child.queue_free()
	_catalog = catalog
	_ordered_controls.clear()
	_controls_by_id.clear()
	for control: GatheringActionButton in candidates:
		actions_container.add_child(control)
		_ordered_controls.append(control)
		_controls_by_id[control.get_action_id()] = control
	return true


func get_ordered_controls() -> Array[GatheringActionButton]:
	return _ordered_controls.duplicate()


func get_control(action_id: String) -> GatheringActionButton:
	return _controls_by_id.get(action_id) as GatheringActionButton


func request_action(action_id: String) -> bool:
	if action_id.is_empty() or not _controls_by_id.has(action_id):
		return false
	action_requested.emit(action_id)
	return true


func _on_control_pressed(control: GatheringActionButton) -> void:
	if control != null:
		request_action(control.get_action_id())
