extends SceneTree

const GridUtility := preload("res://scripts/world/isometric_grid.gd")
const Layering := preload("res://scripts/world/world_layering.gd")
const WorldObjectScene := preload("res://scenes/world/rooftop_world_object.tscn")


func _initialize() -> void:
	var main_scene := load("res://scenes/main.tscn") as PackedScene
	if main_scene == null:
		_fail("Main scene did not load")
		return
	var main: Node = main_scene.instantiate()
	var containers: Array[Node] = main.find_children("WorldObjects", "Node2D", true, false)
	if containers.size() != 1:
		main.free()
		_fail("Main scene must contain exactly one WorldObjects container")
		return
	var container := containers[0]
	if container.get_child_count() != 2:
		main.free()
		_fail("WorldObjects must contain exactly two placeholder instances")
		return
	var higher := container.get_child(0) as RooftopWorldObject
	var lower := container.get_child(1) as RooftopWorldObject
	if higher == null or lower == null or higher.grid_cell == lower.grid_cell:
		main.free()
		_fail("Placeholder instances must expose distinct semantic cells")
		return
	# Main is intentionally not added to the headless tree because startup auto-quits;
	# call the same public contract that each component invokes from _ready().
	if not higher.apply_grid_cell(higher.grid_cell) or not lower.apply_grid_cell(lower.grid_cell):
		main.free()
		_fail("Scene placeholder cells could not apply semantic layers")
		return
	if lower.grid_cell.x + lower.grid_cell.y <= higher.grid_cell.x + higher.grid_cell.y or lower.z_index <= higher.z_index:
		main.free()
		_fail("Greater isometric depth did not receive the greater layer")
		return
	if Layering.layer_for_cell(Vector2i(1, 2)) != Layering.layer_for_cell(Vector2i(2, 1)):
		main.free()
		_fail("Equal-depth cells did not produce the same deterministic base layer")
		return

	var grid: Node = main.get_node("RooftopGrid")
	var camera := main.get_node("RooftopCamera") as Camera2D
	if not grid.select_cell(Vector2i(2, 3)):
		main.free()
		_fail("Could not establish selection state")
		return
	var projection_before: Vector2 = GridUtility.tile_to_world(Vector2i(3, 2))
	var bounds_before: Vector2i = grid.GRID_SIZE
	var selected_before: Vector2i = grid.get_selected_cell()
	var camera_position_before: Vector2 = camera.position
	var camera_zoom_before: Vector2 = camera.zoom
	var cell_before: Vector2i = lower.grid_cell
	var position_before: Vector2 = lower.position
	var layer_before: int = lower.z_index
	if lower.apply_grid_cell(Vector2i(5, 0)):
		main.free()
		_fail("Invalid rooftop cell was accepted")
		return
	if lower.grid_cell != cell_before or lower.position != position_before or lower.z_index != layer_before:
		main.free()
		_fail("Invalid cell changed object state")
		return
	if not lower.apply_grid_cell(cell_before) or GridUtility.tile_to_world(Vector2i(3, 2)) != projection_before or grid.GRID_SIZE != bounds_before:
		main.free()
		_fail("Layer reapplication changed projection or bounds")
		return
	if grid.get_selected_cell() != selected_before or camera.position != camera_position_before or camera.zoom != camera_zoom_before:
		main.free()
		_fail("Layer reapplication changed selection or camera state")
		return

	# Reskin smoke: redirect a replaceable presentation property; semantic layering must survive unchanged.
	var standalone := WorldObjectScene.instantiate() as RooftopWorldObject
	var visual := standalone.get_node("PlaceholderVisual") as Polygon2D
	var original_color: Color = visual.color
	visual.color = Color.MAGENTA
	if not standalone.apply_grid_cell(Vector2i(4, 1)) or standalone.z_index != Layering.layer_for_cell(Vector2i(4, 1)):
		standalone.free()
		main.free()
		_fail("Placeholder substitution changed semantic layering")
		return
	visual.color = original_color
	standalone.free()
	main.free()
	print("PHASE01_VISUAL_LAYERING_SMOKE PASS")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
