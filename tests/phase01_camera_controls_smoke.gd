extends SceneTree

const GridUtility := preload("res://scripts/world/isometric_grid.gd")
const CameraController := preload("res://scripts/world/rooftop_camera.gd")
const RooftopGridScene := preload("res://scenes/world/rooftop_grid.tscn")


func _initialize() -> void:
	var main_scene := load("res://scenes/main.tscn") as PackedScene
	if main_scene == null:
		_fail("Main scene did not load")
		return
	var main: Node = main_scene.instantiate()
	var cameras: Array[Node] = main.find_children("*", "Camera2D", true, false)
	if cameras.size() != 1:
		main.free()
		_fail("Main scene must contain exactly one Camera2D")
		return
	var scene_camera := cameras[0] as Camera2D
	if scene_camera == null or scene_camera.get_script() != CameraController:
		main.free()
		_fail("RooftopCamera is missing its dedicated controller")
		return
	main.free()

	var camera := CameraController.new() as RooftopCamera
	root.add_child(camera)
	camera.position = Vector2(640.0, 360.0)
	camera.target_position = camera.position
	var initial_position: Vector2 = camera.target_position
	camera.pan_by(Vector2(40.0, 20.0))
	if camera.target_position != initial_position - Vector2(40.0, 20.0):
		_fail("Pan request moved in the wrong direction")
		return
	camera.pan_by(Vector2(10000.0, 10000.0))
	if camera.target_position != CameraController.WORLD_BOUNDS.position:
		_fail("Camera did not clamp to minimum bounds")
		return
	camera.pan_by(Vector2(-20000.0, -20000.0))
	if camera.target_position != CameraController.WORLD_BOUNDS.end:
		_fail("Camera did not clamp to maximum bounds")
		return

	camera.zoom = Vector2.ONE
	camera.step_zoom(1)
	if camera.zoom != Vector2(1.25, 1.25):
		_fail("Zoom-in step was not uniform or deterministic")
		return
	camera.step_zoom(-1)
	if camera.zoom != Vector2.ONE:
		_fail("Zoom-out step was not uniform or deterministic")
		return
	camera.step_zoom(100)
	if camera.zoom != Vector2(CameraController.MAX_ZOOM, CameraController.MAX_ZOOM):
		_fail("Maximum zoom clamp failed")
		return
	camera.step_zoom(-100)
	if camera.zoom != Vector2(CameraController.MIN_ZOOM, CameraController.MIN_ZOOM):
		_fail("Minimum zoom clamp failed")
		return

	var grid: Node = RooftopGridScene.instantiate()
	var projection_before: Vector2 = GridUtility.tile_to_world(Vector2i(3, 2))
	var grid_size_before: Vector2i = grid.GRID_SIZE
	if not grid.select_cell(Vector2i(2, 3)):
		_fail("Valid selection failed before camera checks")
		return
	var selected_before: Vector2i = grid.get_selected_cell()
	var original_fill: Color = grid.tile_fill_color
	grid.tile_fill_color = Color.MAGENTA
	camera.pan_by(Vector2(5000.0, -5000.0))
	camera.step_zoom(100)
	if GridUtility.tile_to_world(Vector2i(3, 2)) != projection_before or grid.GRID_SIZE != grid_size_before:
		_fail("Camera or style substitution changed grid projection or bounds")
		return
	if grid.get_selected_cell() != selected_before:
		_fail("Camera or style substitution changed selection")
		return
	if not grid.select_cell(Vector2i(4, 4)) or grid.get_selected_cell() != Vector2i(4, 4):
		_fail("Valid selection failed after camera movement")
		return
	if grid.select_cell(Vector2i(5, 4)) or grid.get_selected_cell() != Vector2i(4, 4):
		_fail("Invalid selection changed state after camera movement")
		return
	grid.tile_fill_color = original_fill
	grid.free()
	camera.queue_free()
	print("PHASE01_CAMERA_CONTROLS_SMOKE PASS")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
