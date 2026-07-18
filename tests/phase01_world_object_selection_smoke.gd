extends SceneTree

const GridUtility := preload("res://scripts/world/isometric_grid.gd")
const WorldObjectScene := preload("res://scenes/world/rooftop_world_object.tscn")


func _initialize() -> void:
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail("Main scene did not load")
		return
	var main: Node = packed.instantiate()
	var containers: Array[Node] = main.find_children("WorldObjects", "Node2D", true, false)
	if containers.size() != 1:
		main.free()
		_fail("Main scene must contain exactly one WorldObjects container")
		return
	var selection := containers[0] as RooftopWorldSelection
	if selection == null or selection.get_child_count() != 2:
		main.free()
		_fail("WorldObjects must own the typed controller and two placeholders")
		return
	var first := selection.get_child(0) as RooftopWorldObject
	var second := selection.get_child(1) as RooftopWorldObject
	if first == null or second == null:
		main.free()
		_fail("Placeholder children are not typed world objects")
		return
	first.apply_grid_cell(first.grid_cell)
	second.apply_grid_cell(second.grid_cell)

	var grid: RooftopGrid = main.get_node("RooftopGrid") as RooftopGrid
	var camera := main.get_node("RooftopCamera") as Camera2D
	grid.select_cell(Vector2i(2, 3))
	var grid_selection_before: Vector2i = grid.get_selected_cell()
	var camera_position_before: Vector2 = camera.position
	var camera_zoom_before: Vector2 = camera.zoom
	var first_cell_before: Vector2i = first.grid_cell
	var first_position_before: Vector2 = first.position
	var first_layer_before: int = first.z_index

	if not selection.select_cell(first.grid_cell):
		main.free()
		_fail("Occupied cell did not select")
		return
	if selection.get_selected_object() != first or selection.get_selected_cell() != first.grid_cell or not first.is_selected() or second.is_selected():
		main.free()
		_fail("Occupied selection identity or marker state is wrong")
		return

	if selection.select_cell(Vector2i(4, 4)):
		main.free()
		_fail("Valid empty cell reported an object")
		return
	if selection.get_selected_object() != null or selection.get_selected_cell() != RooftopWorldSelection.EMPTY_CELL or first.is_selected():
		main.free()
		_fail("Valid empty cell did not clear object selection")
		return

	selection.select_cell(second.grid_cell)
	if selection.select_cell(Vector2i(5, 0)):
		main.free()
		_fail("Invalid cell was accepted")
		return
	if selection.get_selected_object() != second or not second.is_selected():
		main.free()
		_fail("Invalid cell changed retained selection")
		return

	var duplicate := WorldObjectScene.instantiate() as RooftopWorldObject
	duplicate.grid_cell = second.grid_cell
	selection.add_child(duplicate)
	duplicate.apply_grid_cell(duplicate.grid_cell)
	if not selection.select_cell(second.grid_cell) or selection.get_selected_object() != duplicate or second.is_selected() or not duplicate.is_selected():
		main.free()
		_fail("Reverse sibling-order tie-break did not select topmost object")
		return

	selection.clear_selection()
	if selection.get_selected_object() != null or duplicate.is_selected():
		main.free()
		_fail("Explicit clear retained selection")
		return
	if not selection.select_at_local_pointer(GridUtility.tile_to_world(first.grid_cell)) or selection.get_selected_object() != first:
		main.free()
		_fail("Pointer-independent projection API did not delegate to cell selection")
		return

	var marker := first.get_node("SelectionFeedback") as Line2D
	if marker == null or not marker.visible or marker.points.size() < 4:
		main.free()
		_fail("Editor-visible non-color selection geometry is missing")
		return
	var original_color: Color = first.selection_marker_color
	var original_width: float = first.selection_marker_width
	first.selection_marker_color = Color.MAGENTA
	first.selection_marker_width = original_width + 2.0
	first.set_selected(true)
	if selection.get_selected_object() != first or marker.default_color != Color.MAGENTA or marker.width != original_width + 2.0:
		main.free()
		_fail("Presentation-token substitution changed selection behavior")
		return
	first.selection_marker_color = original_color
	first.selection_marker_width = original_width
	first.set_selected(true)

	if first.grid_cell != first_cell_before or first.position != first_position_before or first.z_index != first_layer_before:
		main.free()
		_fail("Selection changed world-object spatial state")
		return
	if grid.get_selected_cell() != grid_selection_before or camera.position != camera_position_before or camera.zoom != camera_zoom_before:
		main.free()
		_fail("Selection changed adjacent grid or camera state")
		return

	main.free()
	print("PHASE01_WORLD_OBJECT_SELECTION_SMOKE PASS")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
