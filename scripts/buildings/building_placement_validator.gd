class_name BuildingPlacementValidator
extends RefCounted


func validate(
	definition: BuildingDefinition,
	anchor: Vector2i,
	grid_bounds: Vector2i,
	occupied_cells: Array
) -> BuildingPlacementResult:
	if definition == null or definition.get_footprint_width() <= 0 or definition.get_footprint_height() <= 0:
		return _result(BuildingPlacementResult.STATUS_INVALID_DEFINITION, anchor, [])
	if grid_bounds.x <= 0 or grid_bounds.y <= 0:
		return _result(BuildingPlacementResult.STATUS_INVALID_GRID_BOUNDS, anchor, [])

	var occupied_lookup: Dictionary = {}
	for occupied: Variant in occupied_cells:
		if typeof(occupied) != TYPE_VECTOR2I:
			return _result(BuildingPlacementResult.STATUS_OCCUPIED_CONFLICT, anchor, [])
		occupied_lookup[occupied] = true

	var candidate_cells: Array[Vector2i] = []
	for y: int in definition.get_footprint_height():
		for x: int in definition.get_footprint_width():
			candidate_cells.append(anchor + Vector2i(x, y))

	for cell: Vector2i in candidate_cells:
		if cell.x < 0 or cell.y < 0 or cell.x >= grid_bounds.x or cell.y >= grid_bounds.y:
			return _result(BuildingPlacementResult.STATUS_OUT_OF_BOUNDS, anchor, candidate_cells)
	for cell: Vector2i in candidate_cells:
		if occupied_lookup.has(cell):
			return _result(BuildingPlacementResult.STATUS_OCCUPIED_CONFLICT, anchor, candidate_cells)
	return _result(BuildingPlacementResult.STATUS_VALID, anchor, candidate_cells)


func _result(status: StringName, anchor: Vector2i, cells: Array[Vector2i]) -> BuildingPlacementResult:
	return BuildingPlacementResult.new(status, anchor, cells)
