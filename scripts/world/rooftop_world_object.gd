class_name RooftopWorldObject
extends Node2D

const GridUtility := preload("res://scripts/world/isometric_grid.gd")
const Layering := preload("res://scripts/world/world_layering.gd")

@export var grid_cell := Vector2i.ZERO
@export_group("Placeholder Selection Style Tokens")
@export var selection_marker_color := Color(1.0, 0.78, 0.18, 1.0)
@export_range(0.5, 8.0, 0.5) var selection_marker_width: float = 3.0

var _selected := false


func _ready() -> void:
	_apply_selection_presentation()
	if not apply_grid_cell(grid_cell):
		push_error("RooftopWorldObject has an invalid initial grid_cell: %s" % grid_cell)


func apply_grid_cell(next_cell: Vector2i) -> bool:
	if not Layering.is_cell_valid(next_cell):
		return false
	grid_cell = next_cell
	position = GridUtility.tile_to_world(grid_cell)
	z_index = Layering.layer_for_cell(grid_cell)
	return true


func set_selected(value: bool) -> void:
	_selected = value
	_apply_selection_presentation()


func is_selected() -> bool:
	return _selected


func _apply_selection_presentation() -> void:
	var marker := get_node_or_null("SelectionFeedback") as Line2D
	if marker == null:
		return
	marker.visible = _selected
	marker.default_color = selection_marker_color
	marker.width = selection_marker_width
