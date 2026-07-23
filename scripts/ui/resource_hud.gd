class_name ResourceHud
extends PanelContainer

@export_group("Reusable presentation components")
@export var row_scene: PackedScene
@export var rows_container_path: NodePath = ^"Margin/Rows"

var _catalog: ResourceCatalog
var _ledger: ResourceLedger
var _rows_by_id: Dictionary = {}
var _ordered_rows: Array[ResourceHudRow] = []


func setup(catalog: ResourceCatalog, ledger: ResourceLedger) -> bool:
	if not _dependencies_are_valid(catalog, ledger):
		return false
	var rows_container := get_node_or_null(rows_container_path) as Container
	if rows_container == null:
		return false
	var candidate_rows: Array[ResourceHudRow] = []
	for definition: ResourceDefinition in catalog.get_ordered_definitions():
		var row := row_scene.instantiate() as ResourceHudRow
		if row == null or not row.bind_definition(definition):
			for candidate: ResourceHudRow in candidate_rows:
				candidate.free()
			return false
		if not row.set_displayed_balance(ledger.get_balance(definition.get_semantic_id())):
			row.free()
			for candidate: ResourceHudRow in candidate_rows:
				candidate.free()
			return false
		candidate_rows.append(row)
	for child: Node in rows_container.get_children():
		rows_container.remove_child(child)
		child.queue_free()
	_catalog = catalog
	_ledger = ledger
	_rows_by_id.clear()
	_ordered_rows.clear()
	for row: ResourceHudRow in candidate_rows:
		rows_container.add_child(row)
		_ordered_rows.append(row)
		_rows_by_id[row.get_semantic_id()] = row
	return true


func refresh() -> bool:
	if not _dependencies_are_valid(_catalog, _ledger):
		return false
	if _ordered_rows.size() != _catalog.size():
		return false
	for row: ResourceHudRow in _ordered_rows:
		var semantic_id: String = row.get_semantic_id()
		if not _rows_by_id.has(semantic_id) or _rows_by_id[semantic_id] != row:
			return false
		if not row.set_displayed_balance(_ledger.get_balance(semantic_id)):
			return false
	return true


func get_ordered_rows() -> Array[ResourceHudRow]:
	return _ordered_rows.duplicate()


func get_row(semantic_id: String) -> ResourceHudRow:
	return _rows_by_id.get(semantic_id) as ResourceHudRow


func _dependencies_are_valid(catalog: ResourceCatalog, ledger: ResourceLedger) -> bool:
	if catalog == null or ledger == null or row_scene == null or catalog.size() <= 0:
		return false
	var definitions: Array[ResourceDefinition] = catalog.get_ordered_definitions()
	if definitions.size() != ledger.get_ordered_ids().size():
		return false
	for definition: ResourceDefinition in definitions:
		if definition == null or not ledger.has_resource(definition.get_semantic_id()):
			return false
	return true
