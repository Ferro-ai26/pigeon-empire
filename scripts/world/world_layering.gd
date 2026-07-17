class_name WorldLayering
extends RefCounted

## Semantic rooftop bounds and draw-layer contract. Presentation must not affect these values.
const ROOFTOP_SIZE := Vector2i(5, 5)
const BASE_LAYER := 10


static func is_cell_valid(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < ROOFTOP_SIZE.x and cell.y < ROOFTOP_SIZE.y


static func layer_for_cell(cell: Vector2i) -> int:
	assert(is_cell_valid(cell), "Cannot calculate a layer for an invalid rooftop cell")
	return BASE_LAYER + cell.x + cell.y
