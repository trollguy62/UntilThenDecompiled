extends Control

signal confirmed

const Keybind = preload("res://data/Keybind.gd")
const InputConfig = preload("res://data/InputConfig.gd")
const SettingsButtonBlock = preload("res://ui/components/SettingsButtonBlock/SettingsButtonBlock.tscn")

@onready var block_container = $ScrollContainer/MarginContainer/VBox/VBoxContainer
@onready var btn_retry = $ScrollContainer/MarginContainer/VBox/HBoxContainer/BtnRetry
@onready var btn_retry_container = $ScrollContainer/MarginContainer/VBox/HBoxContainer
@onready var prospero_align = $ScrollContainer/MarginContainer/VBox/HBoxContainer/ProsperoAlign

var _config: InputConfig

func _ready():
	#FIXME: hack. updates stale data on show (and hide)
	visibility_changed.connect(update)
	Game.ng_plus_changed.connect(func(_ng_plus): update())

	btn_retry.pressed.connect(_on_btn_retry_pressed)
	if OS.get_name() == "Prospero":
		prospero_align.visible = true
		btn_retry_container.size_flags_horizontal = SIZE_SHRINK_END
	update()

func update():
	for c in block_container.get_children():
		c.queue_free()

	_config = _try_load_config()
	var default_keybinds: Array[Keybind] = InputLoader.generate_default_keybinds()

	if _config == null or _config.keybinds.is_empty():
		_config = InputConfig.new(default_keybinds)

	var keybinds = _config.keybinds

	if keybinds.size() < default_keybinds.size():
		# Reconcile missing keybinds
		for i in range(default_keybinds.size()):
			var keybind: Keybind = keybinds[i]
			var default_keybind: Keybind = default_keybinds[i]

			if keybind.action == default_keybind.action:
				continue

			var keybind_exists = false

			for ckb in _config.keybinds:
				if ckb.action == default_keybind.action:
					keybind_exists = true
					break

			if not keybind_exists:
				keybinds.insert(i, default_keybind)

	for entry in keybinds:
		var block = SettingsButtonBlock.instantiate()

		block.keybind = entry
		block.keybind_updated.connect(_on_keybind_updated)
		block_container.add_child(block)

func _on_btn_retry_pressed():
	reload_defaults()

func _on_keybind_updated(keybind):
	_try_unbind_from_all(keybind)
	for b in block_container.get_children():
		b.reset()
	ControllerIcons.refresh()

func _try_unbind_from_all(keybind):
	var actions: Array[StringName] = InputMap.get_actions()
	for b in block_container.get_children():
		var block_bind = b.keybind

		if block_bind == keybind or block_bind.group != keybind.group:
			continue

		var key = keybind.key
		var c_key = keybind.c_key

		#FIXME: hack. InputMap.action_has_event(...) fails for resources loaded from disk :/
		if block_bind.key and block_bind.key.keycode == key.keycode:
			InputMap.action_erase_event(block_bind.action, key)
			block_bind.key = null

		if c_key != null and InputMap.action_has_event(block_bind.action, c_key):
			InputMap.action_erase_event(block_bind.action, c_key)
			block_bind.c_key = null

func reload_defaults():
	InputMap.load_from_project_settings()
	_config.keybinds = InputLoader.generate_default_keybinds()
	var blocks = block_container.get_children()
	for i in blocks.size():
		blocks[i].keybind = _config.keybinds[i]



func save_config():
	_save_config(_config)

func _save_config(content):
	var path = Constants.INPUT_CONFIG_PATH
	var file = FileAccess.open(path, FileAccess.WRITE)
	ResourceSaver.save(content, path)
	assert(Utils.file_exists(path))

func _try_load_config() -> InputConfig:
	var path = Constants.INPUT_CONFIG_PATH
	if Utils.file_exists(path):
		var content = load(path)
		return content as InputConfig
	return null
