class_name IsometricGrid
extends RefCounted

## Shared Phase 1 coordinate contract. World positions address tile centers.
const TILE_SIZE := Vector2i(64, 32)
const HALF_TILE := Vector2(TILE_SIZE.x / 2.0, TILE_SIZE.y / 2.0)


static func tile_to_world(tile: Vector2i) -> Vector2:
	return Vector2(
		(tile.x - tile.y) * HALF_TILE.x,
		(tile.x + tile.y) * HALF_TILE.y
	)


static func world_to_tile(world: Vector2) -> Vector2i:
	var tile_x: float = (world.x / HALF_TILE.x + world.y / HALF_TILE.y) / 2.0
	var tile_y: float = (world.y / HALF_TILE.y - world.x / HALF_TILE.x) / 2.0
	return Vector2i(roundi(tile_x), roundi(tile_y))