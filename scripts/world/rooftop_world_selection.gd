class_name RooftopWorldSelection
extends Node2D

const GridUtility := preload("res://scripts/world/isometric_grid.gd")
const Layering := preload("res://scripts/world/world_layering.gd")
const EMPTY_CELL := Vector2i(-1, -1)

var _selected_object: RooftopWorldObject
var _selected_cell: Vector2i = EMPTY_CELL


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		select_at_local_pointer(to_local(event.position))


func select_at_local_pointer(local_pointer: Vector2) -> bool:
	return select_cell(GridUtility.world_to_tile(local_pointer))


func select_cell(cell: Vector2i) -> bool:
	if not Layering.is_cell_valid(cell):
		return false
	var candidate: RooftopWorldObject = _find_topmost_object(cell)
	_set_selected_object(candidate, cell if candidate != null else EMPTY_CELL)
	return candidate != null


func clear_selection() -> void:
	_set_selected_object(null, EMPTY_CELL)


func get_selected_object() -> RooftopWorldObject:
	if _selected_object != null and not is_instance_valid(_selected_object):
		_selected_object = null
		_selected_cell = EMPTY_CELL
	return _selected_object


func get_selected_cell() -> Vector2i:
	get_selected_object()
	return _selected_cell


func _find_topmost_object(cell: Vector2i) -> RooftopWorldObject:
	for index: int in range(get_child_count() - 1, -1, -1):
		var candidate := get_child(index) as RooftopWorldObject
		if candidate != null and candidate.grid_cell == cell:
			return candidate
	return null


func _set_selected_object(candidate: RooftopWorldObject, cell: Vector2i) -> void:
	var previous: RooftopWorldObject = get_selected_object()
	if previous != null and previous != candidate:
		previous.set_selected(false)
	_selected_object = candidate
	_selected_cell = cell
	if _selected_object != null:
		_selected_object.set_selected(true)
