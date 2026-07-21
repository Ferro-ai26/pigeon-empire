class_name GatheringActionCatalog
extends RefCounted

const STRING_FIELDS: Array[String] = [
	"id",
	"resource_id",
	"display_name",
	"short_description",
	"icon_slot",
	"style_slot",
]
const REQUIRED_FIELDS: Array[String] = [
	"id",
	"resource_id",
	"reward_amount",
	"display_name",
	"short_description",
	"icon_slot",
	"style_slot",
]

var _ordered_definitions: Array[GatheringActionDefinition] = []
var _definitions_by_id: Dictionary = {}
var _last_error: String = ""


func load_from_file(path: String, resource_catalog: ResourceCatalog) -> bool:
	_last_error = ""
	if not FileAccess.file_exists(path):
		_last_error = "gathering_action_file_missing"
		return false
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		_last_error = "gathering_action_file_unreadable"
		return false
	return load_from_json_text(file.get_as_text(), resource_catalog)


func load_from_json_text(json_text: String, resource_catalog: ResourceCatalog) -> bool:
	_last_error = ""
	var parser := JSON.new()
	if parser.parse(json_text) != OK:
		_last_error = "gathering_action_file_invalid_json"
		return false
	if typeof(parser.data) != TYPE_ARRAY:
		_last_error = "gathering_action_root_must_be_array"
		return false
	var entries: Array = parser.data
	return load_from_entries(entries, resource_catalog)


func load_from_entries(entries: Array, resource_catalog: ResourceCatalog) -> bool:
	var candidate_ordered: Array[GatheringActionDefinition] = []
	var candidate_by_id: Dictionary = {}
	_last_error = ""
	if resource_catalog == null or resource_catalog.size() <= 0:
		_last_error = "authoritative_resource_catalog_required"
		return false
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
		for field: String in STRING_FIELDS:
			if typeof(entry[field]) != TYPE_STRING:
				_last_error = "entry_%d_%s_must_be_string" % [index, field]
				return false
			if String(entry[field]).strip_edges().is_empty():
				_last_error = "entry_%d_%s_must_not_be_empty" % [index, field]
				return false
		var raw_reward: Variant = entry["reward_amount"]
		if typeof(raw_reward) != TYPE_INT and typeof(raw_reward) != TYPE_FLOAT:
			_last_error = "entry_%d_reward_amount_must_be_integer" % index
			return false
		var reward_number: float = float(raw_reward)
		if not is_finite(reward_number) or reward_number != floor(reward_number):
			_last_error = "entry_%d_reward_amount_must_be_integer" % index
			return false
		var reward_amount: int = int(reward_number)
		if reward_amount <= 0:
			_last_error = "entry_%d_reward_amount_must_be_positive" % index
			return false
		var action_id: String = entry["id"]
		if action_id != action_id.to_lower() or not action_id.is_valid_identifier():
			_last_error = "entry_%d_id_must_be_lowercase_semantic_id" % index
			return false
		if candidate_by_id.has(action_id):
			_last_error = "duplicate_gathering_action_id_%s" % action_id
			return false
		var resource_id: String = entry["resource_id"]
		if resource_catalog.get_definition(resource_id) == null:
			_last_error = "entry_%d_unknown_resource_id_%s" % [index, resource_id]
			return false
		var definition := GatheringActionDefinition.new(
			action_id,
			resource_id,
			reward_amount,
			String(entry["display_name"]),
			String(entry["short_description"]),
			String(entry["icon_slot"]),
			String(entry["style_slot"])
		)
		candidate_ordered.append(definition)
		candidate_by_id[action_id] = definition
	_ordered_definitions = candidate_ordered
	_definitions_by_id = candidate_by_id
	return true


func get_definition(action_id: String) -> GatheringActionDefinition:
	return _definitions_by_id.get(action_id) as GatheringActionDefinition


func get_ordered_definitions() -> Array[GatheringActionDefinition]:
	return _ordered_definitions.duplicate()


func get_ordered_ids() -> Array[String]:
	var copied_ids: Array[String] = []
	for definition: GatheringActionDefinition in _ordered_definitions:
		copied_ids.append(definition.get_action_id())
	return copied_ids


func size() -> int:
	return _ordered_definitions.size()


func get_last_error() -> String:
	return _last_error
