class_name RooftopCamera
extends Camera2D

const WORLD_BOUNDS := Rect2(Vector2(320.0, 180.0), Vector2(640.0, 360.0))
const MIN_ZOOM := 0.75
const MAX_ZOOM := 1.5
const ZOOM_STEP := 0.25

var target_position: Vector2
var _dragging := false
var _last_pointer_position := Vector2.ZERO


func _ready() -> void:
	target_position = _clamp_to_world_bounds(position)
	position = target_position
	zoom = _clamp_uniform_zoom(zoom.x)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_button := event as InputEventMouseButton
		if mouse_button.button_index == MOUSE_BUTTON_LEFT:
			if mouse_button.pressed:
				begin_pointer_drag(mouse_button.position)
			else:
				end_pointer_drag()
		elif mouse_button.pressed and mouse_button.button_index == MOUSE_BUTTON_WHEEL_UP:
			step_zoom(1)
		elif mouse_button.pressed and mouse_button.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			step_zoom(-1)
	elif event is InputEventMouseMotion and _dragging:
		var mouse_motion := event as InputEventMouseMotion
		update_pointer_drag(mouse_motion.position)


func begin_pointer_drag(pointer_position: Vector2) -> void:
	_dragging = true
	_last_pointer_position = pointer_position


func update_pointer_drag(pointer_position: Vector2) -> void:
	if not _dragging:
		return
	var pointer_delta: Vector2 = pointer_position - _last_pointer_position
	_last_pointer_position = pointer_position
	pan_by(pointer_delta)


func end_pointer_drag() -> void:
	_dragging = false


func pan_by(pointer_delta: Vector2) -> void:
	# Dragging the rooftop right moves the camera left; divide by zoom for stable screen-space motion.
	target_position = _clamp_to_world_bounds(target_position - pointer_delta / zoom.x)
	position = target_position


func step_zoom(step_count: int) -> void:
	var next_zoom: float = zoom.x + float(step_count) * ZOOM_STEP
	zoom = _clamp_uniform_zoom(next_zoom)


func _clamp_to_world_bounds(value: Vector2) -> Vector2:
	return Vector2(
		clampf(value.x, WORLD_BOUNDS.position.x, WORLD_BOUNDS.end.x),
		clampf(value.y, WORLD_BOUNDS.position.y, WORLD_BOUNDS.end.y)
	)


func _clamp_uniform_zoom(value: float) -> Vector2:
	var clamped_zoom := clampf(value, MIN_ZOOM, MAX_ZOOM)
	return Vector2(clamped_zoom, clamped_zoom)
