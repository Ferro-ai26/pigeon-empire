class_name RooftopWorldObject
extends Node2D

const GridUtility := preload("res://scripts/world/isometric_grid.gd")
const Layering := preload("res://scripts/world/world_layering.gd")

@export var grid_cell := Vector2i.ZERO


func _ready() -> void:
	if not apply_grid_cell(grid_cell):
		push_error("RooftopWorldObject has an invalid initial grid_cell: %s" % grid_cell)


func apply_grid_cell(next_cell: Vector2i) -> bool:
	if not Layering.is_cell_valid(next_cell):
		return false
	grid_cell = next_cell
	position = GridUtility.tile_to_world(grid_cell)
	z_index = Layering.layer_for_cell(grid_cell)
	return true
