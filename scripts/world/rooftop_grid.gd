@tool
class_name RooftopGrid
extends Node2D

const GridUtility := preload("res://scripts/world/isometric_grid.gd")
const GRID_SIZE := Vector2i(5, 5)
const EMPTY_SELECTION := Vector2i(-1, -1)
const TILE_COLOR := Color("6f8391")
const TILE_EDGE_COLOR := Color("b7c7cf")
const SELECTED_COLOR := Color("f2c14e")

var selected_cell: Vector2i = EMPTY_SELECTION


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	for y: int in range(GRID_SIZE.y):
		for x: int in range(GRID_SIZE.x):
			var cell := Vector2i(x, y)
			var center: Vector2 = GridUtility.tile_to_world(cell)
			var color := SELECTED_COLOR if cell == selected_cell else TILE_COLOR
			var points := PackedVector2Array([
				center + Vector2(0.0, -GridUtility.HALF_TILE.y),
				center + Vector2(GridUtility.HALF_TILE.x, 0.0),
				center + Vector2(0.0, GridUtility.HALF_TILE.y),
				center + Vector2(-GridUtility.HALF_TILE.x, 0.0),
			])
			draw_colored_polygon(points, color)
			draw_polyline(PackedVector2Array([points[0], points[1], points[2], points[3], points[0]]), TILE_EDGE_COLOR, 2.0)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var local_pointer: Vector2 = to_local(event.position)
		select_cell(GridUtility.world_to_tile(local_pointer))


func is_cell_valid(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < GRID_SIZE.x and cell.y < GRID_SIZE.y


func select_cell(cell: Vector2i) -> bool:
	if not is_cell_valid(cell):
		return false
	selected_cell = cell
	queue_redraw()
	return true


func get_selected_cell() -> Vector2i:
	return selected_cell