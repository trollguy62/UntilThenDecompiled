extends Node

const Keybind = preload("res://data/Keybind.gd")
const InputConfig = preload("res://data/InputConfig.gd")

func _enter_tree():
	var path = Constants.INPUT_CONFIG_PATH
	if Utils.file_exists(path):
		var input_config = load(path)
		if input_config != null:
			apply(input_config)

func apply(input_config: InputConfig):
	for entry in input_config.keybinds:
		var default_key = _get_default_kb_key(entry.action)
		var default_c_key = _get_default_c_key(entry.action)
		if entry.key:
			remap_action(entry.action, default_key, entry.key)
		if entry.c_key:
			remap_action(entry.action, default_c_key, entry.c_key)

func remap_action(action, old_bind, new_bind):
	InputMap.action_erase_event(action, old_bind)
	InputMap.action_add_event(action, new_bind)


func generate_default_keybinds() -> Array[Keybind]:
	var keybinds: Array[Keybind] = []  #Array of Keybinds

	for entry in Constants.REMAPPABLE_ACTIONS:
		if entry.get("ng_plus_only", false) and not Game.ng_plus:
			continue
		
		var default_kb_key = _get_default_kb_key(entry["action"])
		var default_c_key = _get_default_c_key(entry["action"])

		var keybind = Keybind.new(entry["action"], entry["name"], entry["group"], default_kb_key, default_c_key)
		keybinds.append(keybind)

	return keybinds

func _get_default_kb_key(action: String):
	var events = InputMap.action_get_events(action)
	events.reverse()
	for bind in events:
		if bind is InputEventKey:
			return bind
	return null

func _get_default_c_key(action: String):
	var events = InputMap.action_get_events(action)
	events.reverse()
	for bind in events:
		if bind is InputEventJoypadButton or bind is InputEventJoypadMotion:
			return bind
	return null
