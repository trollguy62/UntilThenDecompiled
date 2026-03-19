extends Node

const DebugUserConfig = preload("res://data/DebugUserConfig.gd")
const InitialSettingsScreen = preload("res://ui/screens/Game/InitialSettingsScreen/InitialSettingsScreen.tscn")
const CorruptSavePrompt = preload("res://ui/components/CorruptedSavePrompt/CorruptedSavePrompt.tscn")
const DemoSavePrompt = preload("res://components/DemoSavePrompt/DemoSavePrompt.tscn")

@onready var old_vulkan_warning = $OldVulkanWarning
@onready var splash_screen = $SplashScreen
@onready var cw_screen = $ContentWarningScreen
@onready var cw_list_screen = $ContentWarningListScreen


func _ready():
	cw_screen.fade_duration = splash_screen.fade_duration
	cw_list_screen.fade_duration = splash_screen.fade_duration / 2.0
	
	for screen in [cw_screen, cw_list_screen]:
		screen.visible = false
		screen.process_mode = Node.PROCESS_MODE_DISABLED
	
	if Utils.is_internal_debug() or Game.get_cmd_user_arg("test-scene") != null:
		_set_next_scene()
		return
	
	if has_old_vk_version():
		old_vulkan_warning.show()
		await old_vulkan_warning.dismissed

	old_vulkan_warning.queue_free()
	splash_screen.start()
	await splash_screen.finished
	splash_screen.queue_free()
	
	if not Game.config.skip_content_warning:
		cw_screen.visible = true
		cw_screen.process_mode = Node.PROCESS_MODE_INHERIT
		var show_list: bool = await cw_screen.exited
		cw_screen.queue_free()
		
		if show_list:
			cw_list_screen.visible = true
			cw_list_screen.process_mode = Node.PROCESS_MODE_INHERIT
			cw_list_screen.start()
			await cw_list_screen.exited
			cw_list_screen.queue_free()
	
	await Utils.wait(1)
	_set_next_scene()


func _set_next_scene():
	var scene: PackedScene = null
	var force_to_main_menu = false
	var force_continue = false
	var test_scene_key = Game.get_cmd_user_arg("test-scene")


	if test_scene_key != null:
		var test_scene_duration := float(Game.get_cmd_user_arg("test-scene-duration", "5"))
		return await Game.test_scene_and_quit(test_scene_key, test_scene_duration)

	if Game.corrupted_flag:
		scene = CorruptSavePrompt

	elif Game.first_run:
		if Game.has_demo_save() and not Game.skip_demo_save_flag:
			scene = DemoSavePrompt
		else:
			scene = InitialSettingsScreen

	elif Utils.is_internal_debug():
		var debug_user_config: DebugUserConfig = Game.debug_user_config

		force_to_main_menu = true
		scene = debug_user_config.get_main_scene()
		force_continue = debug_user_config.continue_immediately

	if scene:
		Game.change_scene_to(scene)
	elif force_continue:
		Game.start()
	elif force_to_main_menu:
		Game.go_to_main_menu()
	else:
		Game.launch()


func has_old_vk_version() -> bool:
	if OS.get_name() == "Prospero":
		return false

	if RenderingServer.get_rendering_device() == null:
		#not vulkan
		return false

	var vk_version = RenderingServer.get_video_adapter_api_version().split(".")
	var rec_vk_version = Constants.RECOMMENDED_VK_VERSION.split(".")

	#convert to int for easier comparisons
	for i in vk_version.size():
		if int(vk_version[i]) < int(rec_vk_version[i]):
			return true

	return false
