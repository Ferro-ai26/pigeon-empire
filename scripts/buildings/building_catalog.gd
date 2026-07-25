class_name BuildingCatalog
extends RefCounted

const REQUIRED_FIELDS: Array[String] = [
	"id", "footprint_width", "footprint_height", "construction_costs",
	"storage_contributions", "display_name", "description", "icon_slot",
	"style_slot", "world_visual_slot",
]
const MAX_INTEGER_VALUE := 2147483647

var _ordered_definitions: Array[BuildingDefinition] = []
var _definitions_by_id: Dictionary = {}
var _last_error: String = ""


func load_from_file(path: String, resource_catalog: ResourceCatalog) -> bool:
	_last_error = ""
	if not FileAccess.file_exists(path):
		_last_error = "building_file_missing"
		return false
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		_last_error = "building_file_unreadable"
		return false
	var parser := JSON.new()
	if parser.parse(file.get_as_text()) != OK:
		_last_error = "building_file_invalid_json"
		return false
	if typeof(parser.data) != TYPE_ARRAY:
		_last_error = "building_root_must_be_array"
		return false
	var entries: Array = parser.data
	return load_from_entries(entries, resource_catalog)


func load_from_entries(entries: Array, resource_catalog: ResourceCatalog) -> bool:
	_last_error = ""
	if resource_catalog == null or resource_catalog.size() == 0:
		_last_error = "resource_catalog_required"
		return false
	var candidate_ordered: Array[BuildingDefinition] = []
	var candidate_by_id: Dictionary = {}
	for index: int in entries.size():
		var raw_entry: Variant = entries[index]
		if typeof(raw_entry) != TYPE_DICTIONARY:
			return _reject("entry_%d_must_be_object" % index)
		var entry: Dictionary = raw_entry
		for field: String in REQUIRED_FIELDS:
			if not entry.has(field):
				return _reject("entry_%d_missing_%s" % [index, field])
		var semantic_id := _validated_string(entry["id"], index, "id")
		if semantic_id.is_empty():
			return false
		if semantic_id != semantic_id.to_lower() or not semantic_id.is_valid_identifier():
			return _reject("entry_%d_id_must_be_lowercase_semantic_id" % index)
		if candidate_by_id.has(semantic_id):
			return _reject("duplicate_building_id_%s" % semantic_id)
		var width := _validated_integer(entry["footprint_width"], index, "footprint_width", true)
		if width < 0:
			return false
		var height := _validated_integer(entry["footprint_height"], index, "footprint_height", true)
		if height < 0:
			return false
		var costs_variant: Variant = _validated_resource_map(entry["construction_costs"], index, "construction_costs", resource_catalog, true)
		if costs_variant == null:
			return false
		var costs: Dictionary = costs_variant
		var storage_variant: Variant = _validated_resource_map(entry["storage_contributions"], index, "storage_contributions", resource_catalog, false)
		if storage_variant == null:
			return false
		var storage: Dictionary = storage_variant
		var has_positive_storage := false
		for amount: Variant in storage.values():
			if int(amount) > 0:
				has_positive_storage = true
		if not has_positive_storage:
			return _reject("entry_%d_storage_contributions_requires_positive_amount" % index)
		var strings: Array[String] = []
		for field: String in ["display_name", "description", "icon_slot", "style_slot", "world_visual_slot"]:
			var value := _validated_string(entry[field], index, field)
			if value.is_empty():
				return false
			strings.append(value)
		var definition := BuildingDefinition.new(semantic_id, width, height, costs, storage, strings[0], strings[1], strings[2], strings[3], strings[4])
		candidate_ordered.append(definition)
		candidate_by_id[semantic_id] = definition
	_ordered_definitions = candidate_ordered
	_definitions_by_id = candidate_by_id
	return true


func _validated_string(value: Variant, index: int, field: String) -> String:
	if typeof(value) != TYPE_STRING:
		_reject("entry_%d_%s_must_be_string" % [index, field])
		return ""
	var text: String = value
	if text.strip_edges().is_empty():
		_reject("entry_%d_%s_must_not_be_empty" % [index, field])
		return ""
	return text


func _validated_integer(value: Variant, index: int, field: String, positive: bool) -> int:
	if typeof(value) != TYPE_INT and typeof(value) != TYPE_FLOAT:
		_reject("entry_%d_%s_must_be_integral_number" % [index, field])
		return -1
	var number := float(value)
	if not is_finite(number) or number != floor(number) or number > MAX_INTEGER_VALUE or number < 0.0 or (positive and number <= 0.0):
		_reject("entry_%d_%s_out_of_range" % [index, field])
		return -1
	return int(number)


func _validated_resource_map(value: Variant, index: int, field: String, resource_catalog: ResourceCatalog, positive: bool) -> Variant:
	if typeof(value) != TYPE_DICTIONARY:
		_reject("entry_%d_%s_must_be_object" % [index, field])
		return null
	var source: Dictionary = value
	if source.is_empty():
		_reject("entry_%d_%s_must_not_be_empty" % [index, field])
		return null
	var result: Dictionary = {}
	for resource_id_variant: Variant in source.keys():
		if typeof(resource_id_variant) != TYPE_STRING or String(resource_id_variant).strip_edges().is_empty():
			_reject("entry_%d_%s_resource_id_invalid" % [index, field])
			return null
		var resource_id: String = resource_id_variant
		if resource_catalog.get_definition(resource_id) == null:
			_reject("entry_%d_%s_unknown_resource_%s" % [index, field, resource_id])
			return null
		var amount := _validated_integer(source[resource_id], index, "%s_%s" % [field, resource_id], positive)
		if amount < 0:
			return null
		result[resource_id] = amount
	return result


func _reject(message: String) -> bool:
	_last_error = message
	return false


func get_definition(semantic_id: String) -> BuildingDefinition:
	return _definitions_by_id.get(semantic_id) as BuildingDefinition


func get_ordered_definitions() -> Array[BuildingDefinition]:
	return _ordered_definitions.duplicate()


func size() -> int:
	return _ordered_definitions.size()


func get_last_error() -> String:
	return _last_error
