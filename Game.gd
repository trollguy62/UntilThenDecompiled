extends Node

signal paused_changed(paused: bool)
signal playthrough_changed(playthrough: int)
signal ng_plus_changed(ng_plus: bool)
signal will_change_scene()

const LAUNCH_SCENE_PATH = "res://scenes/_cutscenes/pre_opening/PreOpening.tscn"
const SCENE_DIR_PATH = "res://assets/databases/scene_directory.json"
const DEBUG_USER_CONFIG_PATH = "res://debug_user_config.tres"

const FIRST_SCENE_KEY = "1.1a"
const FLAG_VERBOSE = "verbose"

const SceneDirectory = preload("res://data/SceneDirectory.gd")
const SettingsConfig = preload("res://data/SettingsConfig.gd")
const Savegame = preload("res://data/Savegame.gd")
const DistPlatform = preload("res://components/DistPlatform/DistPlatform.gd")
const DebugUserConfig = preload("res://data/DebugUserConfig.gd")

const MainMenuScreen = preload("res://ui/screens/Game/MainMenu/MainMenuScreen.tscn")
const LoadingScreen = preload("res://ui/screens/Game/LoadingScreen/LoadingScreen.tscn")
const BlankScreen = preload("res://ui/screens/Game/BlankScreen.tscn")

var paused: bool:
	set(value):
		get_tree().paused = value
		paused_changed.emit(value)
	get:
		return get_tree().paused

var playthrough: int:
	set(value):
		if value == playthrough:
			return

		assert(value >= 1 && value <= Constants.PLAYTHROUGH_COUNT)
		savegame.playthrough = value
		save_savegame()
		playthrough_changed.emit(playthrough)
	get:
		return savegame.playthrough

var time: int:
	set(value):
		time = value
		_time_pivot = int(Time.get_unix_time_from_system())
	get:
		return time + int(Time.get_unix_time_from_system()) - _time_pivot

var has_internet = true  # TODO relocate this state somewhere else appropriate

var scene_directory: SceneDirectory
var first_run: bool:
	set(value):
		savegame.first_run = value
		save_savegame()
	get:
		return savegame.first_run

var ng_plus: bool:
	set(value):
		if savegame.ng_plus != value:
			savegame.ng_plus = value
			save_savegame()
			ng_plus_changed.emit(value)
	get:
		return savegame.ng_plus

var savegame: Savegame: #readonly
	get:
		return savegame

var _config: SettingsConfig
var config: SettingsConfig: #readonly
	get:
		return _config

var _debug_user_config: DebugUserConfig
var debug_user_config: DebugUserConfig:
	get:
		return _debug_user_config

var dist_platform: DistPlatform:
	get:
		return dist_platform

var _time_pivot := 0
var _cmd_user_args := {} # Map<String, String>
var _scene_params := {}
var corrupted_flag := false
var skip_demo_save_flag := false


func _enter_tree():
	self.time = 1415950200


func _exit_tree():
	print("Until then...")


func _ready():
	seed(42069)

	_read_cmd_user_args()
	_setup_debug_user_config()
	_setup_dist_platform()
	_setup_settings_config()

	_load_savegame()
	scene_directory = SceneDirectory.new(Utils.read_json_file(SCENE_DIR_PATH))


func _read_cmd_user_args():
	for arg in OS.get_cmdline_user_args():
		if arg.find("=") > -1:
			var key_value = arg.split("=")
			_cmd_user_args[key_value[0].lstrip("--")] = key_value[1]
		else:
			_cmd_user_args[arg.lstrip("--")] = ""


func _setup_dist_platform():
	if Utils.has_feature("steam"):
		var SteamPlatform = load("res://components/DistPlatform/SteamPlatform.gd")
		dist_platform = SteamPlatform.new()
	elif Utils.has_feature("xbox"):
		var XboxPlatform = load("res://components/DistPlatform/XboxPlatform.gd")
		dist_platform = XboxPlatform.new()
	elif Utils.has_feature("prospero"):
		var PSPlatform = load("res://components/DistPlatform/PlaystationPlatform.gd")
		dist_platform = PSPlatform.new()
	else:
		dist_platform = DistPlatform.new()
		print("No dist platform detected")

	add_child(dist_platform)

	var success = dist_platform.setup()
	if success:
		print("Dist platform setup success")
	else:
		print("Dist platform setup failed")
		get_tree().quit(1)


func _load_resource(path: String, default: Callable, save: bool = true):  # default: () -> Resource
	if ResourceLoader.exists(path):
		return load(path)
	else:
		var res = default.call()
		if save:
			ResourceSaver.save(res, path)
		return res

func _load_savegame():
	# Eliminate some indeterminism by always having empty savegame on record/replay
	if Game.record_replay_is_active():
		savegame = Savegame.new()
		return

	if not FileAccess.file_exists(Constants.SAVEGAME_PATH):
		#savegame is missing
		#fill it with a default save
		#this will trigger either new game or demo save check down the line
		savegame = Savegame.new()
		return

	if not _try_load_savegame(Constants.SAVEGAME_PATH):
		printerr("ERROR: Main save failed to load. Trying backup save...")
		
		if not _try_load_savegame(Constants.SAVEGAME_BAK_PATH):
			printerr("ERROR: Backup save failed to load.")
			#backup save failed to load
			#fill it with a default save for now
			savegame = Savegame.new()

func _try_load_savegame(path) -> bool:
	var save = _load_resource(path, func(): return null)

	if save == null:
		return false

	if save.md5 == Constants.OLD_SAVE_VERSION_MAGIC:
		#old version, migrate
		save.migrate()
		corrupted_flag = false
		savegame = save
		save_savegame()
		return true

	elif save.md5 != save.compute_md5():
		#something's not right
		#consider savegame corrupted
		printerr("ERROR: Save corruption detected.")
		corrupted_flag = true
		return false

	corrupted_flag = false
	savegame = save
	return true


func _setup_settings_config():
	if Game.record_replay_is_active():
		# Eliminate some indeterminism by always having default settings on record/replay
		# TODO: What about testing on other locales?
		_config = get_default_config()
	else:
		_config = _load_resource(Constants.SETTINGS_CONFIG_PATH, get_default_config)

	assert(config is SettingsConfig)

	# SICKHEAD: Log if the game is in the shader caching mode.
	var is_prospero = OS.get_name() == "Prospero"
	var save_source = ProjectSettings.get_setting("rendering/shader_compiler/shader_cache/save_source")
	if save_source && !is_prospero:
		print("NOTE: Saving of shader source to shader cache enabled (for console shader generation).")

	# SICKHEAD: If Prospero we want full screen at 1440p.
	if is_prospero:
		print("Setting Prospero resolution 2560x1440")
		_config.screen_res = Vector2i(2560, 1440)
		_config.fullscreen = true

	# SICKHEAD: Force certain graphics settings on PS and on
	# the PC game when we are dumping the shader cache.
	if is_prospero || save_source:
		print("Setting Prospero graphics presets.")
		_config.volumetrics = 4 # High
		_config.aa = 0 # No AA
		_config.gi_quality = 2 # High
		_config.shadow_quality = 4 # Ultra
		_config.bokeh_quality = 4 # Ultra

	# SICKHEAD: Unlock all scenes by default in Prospero debug builds.
	if is_prospero && Utils.is_debug():
		_config.debug_unlock_all_scenes = true

	if _config.setup(get_viewport()):
		save_config()
	_config.apply()


func get_default_config():
	var config = SettingsConfig.new()
	config.locale = Utils.get_best_available_locale_from_os()
	return config


func _setup_debug_user_config():
	_debug_user_config = _load_resource(
		DEBUG_USER_CONFIG_PATH, func(): return DebugUserConfig.new(), false
	)


func save_savegame():
	if Game.record_replay_is_active():
		return

	if FileAccess.file_exists(Constants.SAVEGAME_PATH):
		var dir = DirAccess.open(Constants.SAVEGAME_PATH.get_base_dir())
		dir.copy(Constants.SAVEGAME_PATH, Constants.SAVEGAME_BAK_PATH)

	ResourceSaver.save(savegame, Constants.SAVEGAME_PATH)

func save_config():
	ResourceSaver.save(_config, Constants.SETTINGS_CONFIG_PATH)


func start():
	if not is_new_game():
		to_scene_key(savegame.current_scene_key)

func is_pausable():
	return not Game.paused


func is_new_game() -> bool:
	return savegame.current_scene_key == FIRST_SCENE_KEY and not savegame.ng_plus


func is_scene_key_valid(scene_key: String) -> bool:
	return scene_directory.scene_exists(scene_key)


func get_scene_param(key: String, default = null):
	return _scene_params.get(key, default)


func has_scene_param(key: String) -> bool:
	return _scene_params.has(key)


# Use this instead of `get_tree().change_scene_to_file()`
func change_scene(path: String, params: Dictionary = {}):
	change_scene_to(load(path), params)


# Use this instead of `get_tree().change_scene_to_packed()`
func change_scene_to(packed_scene: PackedScene, params: Dictionary = {}):
	will_change_scene.emit()
	_scene_params = params
	get_tree().change_scene_to_packed(packed_scene)


func _use_threaded_loading() -> bool:
	return false


func to_scene_key(key: String, params: Dictionary = {}, no_load_screen: bool = false):
	assert(scene_directory.scene_exists(key))

	if Utils.is_debug():
		print("Loading scene: ", key)
		StatsMonitor.set_scene_id_label(key)

	var last_scene = Utils.get_root_scene()
	var last_key = ""
	var new_chapter_text = ""

	if last_scene is Scene:
		last_key = last_scene.key
		await last_scene.exit_scene()

	if not no_load_screen and scene_directory.is_from_different_chapters(key, last_key):
		var chapter_index = scene_directory.get_scene_info(key).chapter_index
		new_chapter_text = scene_directory.get_chapter_name(chapter_index)

	if not key in ["pre_opening", "credits", "lo.post"]:
		savegame.current_scene_key = key
		savegame.unlock_scene(key)

	save_savegame()

	var intermediate_screen = BlankScreen if no_load_screen else LoadingScreen
	if no_load_screen:
		change_scene_to(BlankScreen)
	else:
		change_scene_to(LoadingScreen, { "chapter_text": new_chapter_text })

	Story.clear_cache()
	FocusManager.clear()

	# Prevent getting stuck in main menu after choosing/continuing
	# 	 a scene that takes very long to load
	await Utils.wait_frames(2)

	var path = scene_directory.get_scene_info(key).path
	var scene = null
	var t0 = Time.get_ticks_msec()

	if _use_threaded_loading():
		assert(ResourceLoader.load_threaded_request(path) == OK)

		while true:
			var status = ResourceLoader.load_threaded_get_status(path)

			if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				await Utils.wait(0.5)
			else:
				assert(status == ResourceLoader.THREAD_LOAD_LOADED)
				scene = ResourceLoader.load_threaded_get(path)
				break
	else:
		scene = load(path)
		await Utils.wait(1)

	if scene != null and scene is PackedScene:
		params["scene_key"] = key
		await change_scene_to(scene, params)
	else:
		print("Tried to change scene to '%s' but failed miserably" % path)
		get_tree().quit(1)


func to_next_scene(params: Dictionary = {}, no_load_screen: bool = false):
	var next_scene_key = ""
	var scene_key = ""
	var scene = Utils.get_root_scene()

	if scene is Scene:
		scene_key = scene.key

	if scene_directory.scene_exists(scene_key):
		next_scene_key = scene_directory.get_next_scene_key_of(scene_key)

	if next_scene_key != "":
		if scene_directory.get_scene_info(next_scene_key).is_hidden():
			no_load_screen = true

		to_scene_key(next_scene_key, params, no_load_screen)
	else:
		print("Tried to go to next scene of '%s' but failed miserably" % scene_key)
		get_tree().quit(1)


func test_scene_and_quit(key: String, duration: float):
	await to_scene_key(key)
	await Utils.wait(duration)
	get_tree().quit()


func launch():
	change_scene(LAUNCH_SCENE_PATH)


func go_to_main_menu():
	AudioUtils.stop_all_persists()
	FocusManager.clear()

	if savegame.ng_plus and not savegame.ng_plus_shown_post:
		savegame.ng_plus_shown_post = true
		to_scene_key("lo.post")
	elif is_new_game():
		to_scene_key(FIRST_SCENE_KEY, {"with_main_menu": true})
	else:
		change_scene_to(MainMenuScreen)


func get_cmd_user_arg(name: String, default = null):
	if _cmd_user_args.has(name):
		return _cmd_user_args.get(name)
	else:
		return default


func is_verbose() -> bool:
	return OS.get_cmdline_args().has(FLAG_VERBOSE)


func has_demo_save() -> bool:
	if OS.get_name() == "Prospero":
		return false
	return FileAccess.file_exists(get_demo_save_path())


func get_demo_base_path():
	var s_file = "savegame.res"
	var base_dir = ProjectSettings.globalize_path("user://")
	base_dir = base_dir.replace("Until Then/", "Until Then Demo/")

	return base_dir


func get_demo_save_path():
	return get_demo_base_path() + "savegame.res"


func record_replay_is_active() -> bool:
	return is_instance_valid(RecordReplay) and not RecordReplay.is_queued_for_deletion()


func record_replay_pause() -> void:
	if record_replay_is_active():
		# This is not an encapsulation violation. (More like autoload abuse)
		# This is intentionally named with an underscore to discourage and hopefully prevent
		#   direct use of this method. See its definition.
		RecordReplay._pause()


func record_replay_resume() -> void:
	if record_replay_is_active():
		# This is not an encapsulation violation. (More like autoload abuse)
		# This is intentionally named with an underscore to discourage and hopefully prevent
		#   direct use of this method. See its definition.
		RecordReplay._resume()
