extends SceneTree

const GridUtility := preload("res://scripts/world/isometric_grid.gd")
const RooftopGridScene := preload("res://scenes/world/rooftop_grid.tscn")


func _initialize() -> void:
	for y: int in range(5):
		for x: int in range(5):
			var cell := Vector2i(x, y)
			var world: Vector2 = GridUtility.tile_to_world(cell)
			if GridUtility.world_to_tile(world) != cell:
				_fail("Projection round trip failed for %s" % cell)
				return

	var main_scene := load("res://scenes/main.tscn") as PackedScene
	if main_scene == null:
		_fail("Main scene did not load")
		return
	var main: Node = main_scene.instantiate()
	if main.get_node_or_null("RooftopGrid") == null:
		main.free()
		_fail("Main scene is missing RooftopGrid")
		return
	main.free()

	var grid: Node = RooftopGridScene.instantiate()
	if grid == null:
		_fail("Rooftop grid did not instantiate")
		return
	if not grid.is_cell_valid(Vector2i(0, 0)) or not grid.is_cell_valid(Vector2i(4, 4)):
		grid.free()
		_fail("Valid grid bounds were rejected")
		return
	if grid.is_cell_valid(Vector2i(-1, 0)) or grid.is_cell_valid(Vector2i(5, 4)):
		grid.free()
		_fail("Invalid grid bounds were accepted")
		return
	if not grid.select_cell(Vector2i(2, 3)) or grid.get_selected_cell() != Vector2i(2, 3):
		grid.free()
		_fail("Valid selection did not update state")
		return
	if grid.select_cell(Vector2i(5, 3)) or grid.get_selected_cell() != Vector2i(2, 3):
		grid.free()
		_fail("Invalid selection changed state")
		return
	# Reskin smoke: redirect a semantic style token and prove mechanics remain unchanged.
	var original_fill: Color = grid.tile_fill_color
	grid.tile_fill_color = Color.MAGENTA
	if grid.tile_fill_color == original_fill:
		grid.free()
		_fail("Placeholder style token could not be redirected")
		return
	if grid.get_selected_cell() != Vector2i(2, 3) or not grid.is_cell_valid(Vector2i(4, 4)):
		grid.free()
		_fail("Style token substitution changed grid mechanics")
		return
	grid.tile_fill_color = original_fill
	grid.free()
	print("PHASE01_ISOMETRIC_GRID_SMOKE PASS")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)