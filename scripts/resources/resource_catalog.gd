class_name ResourceCatalog
extends RefCounted

const REQUIRED_FIELDS: Array[String] = [
	"id",
	"display_name",
	"short_description",
	"icon_slot",
	"style_slot",
]

var _ordered_definitions: Array[ResourceDefinition] = []
var _definitions_by_id: Dictionary = {}
var _last_error: String = ""


func load_from_file(path: String) -> bool:
	_last_error = ""
	if not FileAccess.file_exists(path):
		_last_error = "resource_file_missing"
		return false
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		_last_error = "resource_file_unreadable"
		return false
	var parser := JSON.new()
	if parser.parse(file.get_as_text()) != OK:
		_last_error = "resource_file_invalid_json"
		return false
	if typeof(parser.data) != TYPE_ARRAY:
		_last_error = "resource_root_must_be_array"
		return false
	var entries: Array = parser.data
	return load_from_entries(entries)


func load_from_entries(entries: Array) -> bool:
	var candidate_ordered: Array[ResourceDefinition] = []
	var candidate_by_id: Dictionary = {}
	_last_error = ""
	for index: int in entries.size():
		var raw_entry: Variant = entries[index]
		if typeof(raw_entry) != TYPE_DICTIONARY:
			_last_error = "entry_%d_must_be_object" % index
			return false
		var entry: Dictionary = raw_entry
		for field: String in REQUIRED_FIELDS:
			if not entry.has(field):
				_last_error = "entry_%d_missing_%s" % [index, field]
				return false
			if typeof(entry[field]) != TYPE_STRING:
				_last_error = "entry_%d_%s_must_be_string" % [index, field]
				return false
			if String(entry[field]).strip_edges().is_empty():
				_last_error = "entry_%d_%s_must_not_be_empty" % [index, field]
				return false
		var semantic_id: String = entry["id"]
		if semantic_id != semantic_id.to_lower() or not semantic_id.is_valid_identifier():
			_last_error = "entry_%d_id_must_be_lowercase_semantic_id" % index
			return false
		if candidate_by_id.has(semantic_id):
			_last_error = "duplicate_resource_id_%s" % semantic_id
			return false
		var definition := ResourceDefinition.new(
			semantic_id,
			String(entry["display_name"]),
			String(entry["short_description"]),
			String(entry["icon_slot"]),
			String(entry["style_slot"])
		)
		candidate_ordered.append(definition)
		candidate_by_id[semantic_id] = definition
	_ordered_definitions = candidate_ordered
	_definitions_by_id = candidate_by_id
	return true


func get_definition(semantic_id: String) -> ResourceDefinition:
	return _definitions_by_id.get(semantic_id) as ResourceDefinition


func get_ordered_definitions() -> Array[ResourceDefinition]:
	return _ordered_definitions.duplicate()


func size() -> int:
	return _ordered_definitions.size()


func get_last_error() -> String:
	return _last_error
