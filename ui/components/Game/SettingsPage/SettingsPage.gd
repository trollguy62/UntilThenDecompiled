extends "res://ui/components/Game/Page.gd"

const SettingsConfig = preload("res://data/SettingsConfig.gd")

const CONFIG_PATH = "user://settings.res"

const SCREEN_RES_ITEMS = [
	{"name": "1280 x 720", "value": Vector2i(1280, 720)},
	{"name": "1366 x 768", "value": Vector2i(1366, 768)},
	{"name": "1600 x 900", "value": Vector2i(1600, 900)},
	{"name": "1920 x 1080", "value": Vector2i(1920, 1080)},
	{"name": "2560 x 1440", "value": Vector2i(2560, 1440)},
	{"name": "3840 x 2160", "value": Vector2i(3840, 2160)},
	{"name": "2048 x 1152", "value": Vector2i(2048, 1152)},
	{"name": "3200 x 1800", "value": Vector2i(3200, 1800)},
	{"name": "5120 x 2880", "value": Vector2i(5120, 2880)},
	{"name": "7680 x 4320", "value": Vector2i(7680, 4320)},
]

@onready var screen_res_option = $MarginContainer/VBox/ScrollContainer/Content/Video/Grid/ScreenResOption
@onready var fullscreen_checkbox = $MarginContainer/VBox/ScrollContainer/Content/Video/Grid/FullscreenCheckbox
@onready var aa_option = $MarginContainer/VBox/ScrollContainer/Content/Graphics/Grid/AaOption
@onready var volumetrics_option = $MarginContainer/VBox/ScrollContainer/Content/Graphics/Grid/VolumetricsOption
@onready var gi_option = $MarginContainer/VBox/ScrollContainer/Content/Graphics/Grid/GIOption
@onready var glow_option = $MarginContainer/VBox/ScrollContainer/Content/Graphics/Grid/GlowOption
@onready var shadow_option = $MarginContainer/VBox/ScrollContainer/Content/Graphics/Grid/ShadowOption
@onready var reflections_option = $MarginContainer/VBox/ScrollContainer/Content/Graphics/Grid/ReflectionsOption
@onready var ssao_option = $MarginContainer/VBox/ScrollContainer/Content/Graphics/Grid/SsaoOption
@onready var bokeh_option = $MarginContainer/VBox/ScrollContainer/Content/Graphics/Grid/BokehOption
@onready var debanding_checkbox = $MarginContainer/VBox/ScrollContainer/Content/Graphics/Grid/DebandingCheckbox
@onready var master_vol_slider = $MarginContainer/VBox/ScrollContainer/Content/Sound/Grid/MasterVolSlider
@onready var master_vol_indicator = $MarginContainer/VBox/ScrollContainer/Content/Sound/Grid/MasterVolIndicator
@onready var music_vol_slider = $MarginContainer/VBox/ScrollContainer/Content/Sound/Grid/MusicVolSlider
@onready var music_vol_indicator = $MarginContainer/VBox/ScrollContainer/Content/Sound/Grid/MusicVolIndicator
@onready var sfx_vol_slider = $MarginContainer/VBox/ScrollContainer/Content/Sound/Grid/SfxVolSlider
@onready var sfx_vol_indicator = $MarginContainer/VBox/ScrollContainer/Content/Sound/Grid/SfxVolIndicator
@onready var text_speed_slider = $MarginContainer/VBox/ScrollContainer/Content/Game/HBoxContainer/Grid/TextSpeedSlider
@onready var language_option = $MarginContainer/VBox/ScrollContainer/Content/Game/HBoxContainer/Grid/LanguageOption
@onready var skip_cw_checkbox = $MarginContainer/VBox/ScrollContainer/Content/Game/HBoxContainer/Grid/SkipCwCheckbox
@onready var credits_label = $MarginContainer/VBox/ScrollContainer/Content/Game/HBoxContainer/Grid/CreditsLabel
@onready var credits_button = $MarginContainer/VBox/ScrollContainer/Content/Game/HBoxContainer/Grid/CreditsButton
@onready var rhythm_offset_spinbox = $MarginContainer/VBox/ScrollContainer/Content/Game/HBoxContainer/Grid/RhythmOffsetSpinbox
@onready var rhythm_lane_speed_spinbox = $MarginContainer/VBox/ScrollContainer/Content/Game/HBoxContainer/Grid/RhythmLaneSpeedSpinbox

@onready var debug_unlock_all_scenes_label = $MarginContainer/VBox/ScrollContainer/Content/Game/HBoxContainer/Grid/DebugUnlockAllScenesLabel
@onready var debug_unlock_all_scenes_checkbox = $MarginContainer/VBox/ScrollContainer/Content/Game/HBoxContainer/Grid/DebugUnlockAllScenesCheckbox
@onready var debug_playthrough_label = $MarginContainer/VBox/ScrollContainer/Content/Game/HBoxContainer/Grid/DebugPlaythroughLabel
@onready var debug_playthrough_option = $MarginContainer/VBox/ScrollContainer/Content/Game/HBoxContainer/Grid/DebugPlaythroughOption

@onready var reset_btn = $MarginContainer/VBox/HBoxContainer/ResetBtn
@onready var back_btn = $MarginContainer/VBox/HBoxContainer/BackBtn
@onready var sfx_vol_test = $SfxVolTest

@onready var aside_container = $MarginContainer/VBox/ScrollContainer/Content/Game/HBoxContainer/AsideAnchor/AsideContainer
@onready var text_speed_preview = $MarginContainer/VBox/ScrollContainer/Content/Game/HBoxContainer/AsideAnchor/AsideContainer/TextSpeedPreview
@onready var offset_calibrator = $MarginContainer/VBox/ScrollContainer/Content/Game/HBoxContainer/AsideAnchor/AsideContainer/RhythmCalib/OffsetCalibrator
@onready var tween = Threen.new()

@onready var confirm_page = $PageHolder/SettingsConfirmationPage
@onready var controls_page = $PageHolder/SettingsControlsPage
@onready var reset_defaults_page = $PageHolder/ResetDefaultsPage
@onready var settings_warning_page = $PageHolder/SettingsWarningPage

var _t := 0.0
var _config: SettingsConfig
var _updating := false

var _dismiss_prop: String
var _dismiss_value

var is_initial_settings := false


func _ready():
	add_child(tween)
	_config = Game.config

	if OS.get_name() == "Prospero":
		reset_btn.visible = false

	if not Utils.is_debug():
		debug_unlock_all_scenes_label.visible = false
		debug_unlock_all_scenes_checkbox.visible = false
		debug_playthrough_label.visible = false
		debug_playthrough_option.visible = false

	aa_option.item_selected.connect(_set_config_generic.bind("aa"))
	volumetrics_option.item_selected.connect(_set_config_generic.bind("volumetrics"))
	gi_option.item_selected.connect(_set_config_generic.bind("gi_quality"))
	glow_option.item_selected.connect(_set_config_generic.bind("glow_quality"))
	shadow_option.item_selected.connect(_set_config_generic.bind("shadow_quality"))
	reflections_option.item_selected.connect(_set_config_generic.bind("reflections_quality"))
	ssao_option.item_selected.connect(_set_config_generic.bind("ssao_quality"))
	bokeh_option.item_selected.connect(_set_config_generic.bind("bokeh_quality"))

	screen_res_option.item_selected.connect(_set_screen_res_option)
	fullscreen_checkbox.toggled.connect(_set_fullscreen)
	debanding_checkbox.toggled.connect(_set_config_generic.bind("debanding"))
	master_vol_slider.value_changed.connect(_set_master_vol)
	music_vol_slider.value_changed.connect(_set_music_vol)
	sfx_vol_slider.value_changed.connect(_set_sfx_vol)
	text_speed_slider.value_changed.connect(_set_text_speed)
	language_option.item_selected.connect(_set_language)
	skip_cw_checkbox.toggled.connect(_set_config_generic.bind("skip_content_warning"))
	credits_button.pressed.connect(_show_credits)

	rhythm_offset_spinbox.value_changed.connect(_set_config_generic.bind("rhythm_offset_ms"))
	rhythm_lane_speed_spinbox.value_changed.connect(_set_config_generic.bind("rhythm_lane_speed_mult"))

	debug_unlock_all_scenes_checkbox.toggled.connect(_set_config_generic.bind("debug_unlock_all_scenes"))
	debug_playthrough_option.item_selected.connect(_set_debug_playthrough)

	text_speed_slider.focus_entered.connect(_fade_aside_container.bind(true, 0))
	text_speed_slider.focus_exited.connect(_fade_aside_container.bind(false, 0))

	rhythm_offset_spinbox.focus_entered.connect(_on_rhythm_offset_spinbox_focus_changed.bind(true))
	rhythm_offset_spinbox.focus_exited.connect(_on_rhythm_offset_spinbox_focus_changed.bind(false))
	rhythm_offset_spinbox.pressed.connect(offset_calibrator.trigger)

	offset_calibrator.offset_suggested.connect(func(ms): rhythm_offset_spinbox.value = ms)

	reset_btn.pressed.connect(_on_reset_btn_pressed)
	back_btn.pressed.connect(func(): _page_container.pop())

	confirm_page.confirmed.connect(_on_confirmation_confirmed)
	confirm_page.dismissed.connect(_on_confirmation_dismissed)
	reset_defaults_page.confirmed.connect(_on_settings_reset_confirmed)


func _enter():
	super._enter()

	_updating = true

	_update_config_prop("aa", aa_option)
	_update_config_prop("volumetrics", volumetrics_option)
	_update_config_prop("gi_quality", gi_option)
	_update_config_prop("glow_quality", glow_option)
	_update_config_prop("shadow_quality", shadow_option)
	_update_config_prop("reflections_quality", reflections_option)
	_update_config_prop("ssao_quality", ssao_option)
	_update_config_prop("bokeh_quality", bokeh_option)

	_update_screen_res()
	_update_text_speed_preview()
	_update_language()
	_update_debug_playthrough()
	_update_controls()

	fullscreen_checkbox.button_pressed = _config.fullscreen
	debanding_checkbox.button_pressed = _config.debanding
	skip_cw_checkbox.button_pressed = _config.skip_content_warning

	for node in [credits_label, credits_button]:
		node.visible = not Game.paused

	rhythm_offset_spinbox.value = _config.rhythm_offset_ms
	rhythm_lane_speed_spinbox.value = _config.rhythm_lane_speed_mult

	master_vol_slider.value = _config.master_vol
	_set_master_vol(_config.master_vol)

	music_vol_slider.value = _config.music_vol
	_set_music_vol(_config.music_vol)

	sfx_vol_slider.value = _config.sfx_vol
	_set_sfx_vol(_config.sfx_vol)

	text_speed_slider.value = _config.text_speed

	debug_unlock_all_scenes_checkbox.button_pressed = _config.debug_unlock_all_scenes

	aside_container.modulate = Color.TRANSPARENT
	for child in aside_container.get_children():
		child.visible = false

	if is_initial_settings:
		_init_for_initial_settings()

	_updating = false


func _process(delta):
	_t += delta


func _exit():
	super._exit()
	Game.save_config()
	controls_page.save_config()


func _on_reset_btn_pressed():
	_page_container.push(reset_defaults_page)


func _on_controls_btn_pressed():
	_page_container.push(controls_page)


func _on_confirmation_confirmed():
	Game.save_config()


func _on_confirmation_dismissed():
	_config[_dismiss_prop] = _dismiss_value


func _ask_confirmation(prop: String):
	_dismiss_prop = prop
	_dismiss_value = _config[prop]
	_page_container.push(confirm_page)

func _push_warning(message: String):
	settings_warning_page.message = message
	_page_container.push(settings_warning_page)

func _on_settings_reset_confirmed():
	if OS.get_name() == "Prospero":
		return

	if !self.is_inside_tree():
		await tree_entered

	#FIXME: breaks encap, also a hack
	var def_config = Game.get_default_config()
	def_config.setup(get_viewport())

	for prop in Game.config.get_property_list():
		if prop["name"] in _config:
			Game.config.set(prop["name"], def_config[prop["name"]])
			_config.set(prop["name"], def_config[prop["name"]])

	controls_page.reload_defaults()


func _update_screen_res():
	screen_res_option.clear()

	var max_width = DisplayServer.screen_get_size().x
	var selected = 0

	for i in range(SCREEN_RES_ITEMS.size()):
		var item = SCREEN_RES_ITEMS[i]
		if item.value.x > max_width:
			break

		screen_res_option.add_item(item.name)
		if _config.screen_res == item.value:
			selected = i

	screen_res_option.selected = selected


func _update_config_prop(name: String, option: OptionButton):
	option.clear()

	for item in _config.get_prop_preset_names(name):
		option.add_item(item)

	option.selected = _config.get(name)


func _update_language():
	var locales := Constants.LOCALES
	language_option.clear()

	for loc in locales:
		var lang_name = locales[loc]
		language_option.add_item(lang_name)

	language_option.selected = locales.keys().find(_config.locale)


func _update_debug_playthrough():
	debug_playthrough_option.clear()
	for i in range(Constants.PLAYTHROUGH_COUNT):
		debug_playthrough_option.add_item("Pt%d" % (i + 1))
	debug_playthrough_option.selected = Game.playthrough - 1


func _update_controls():
	controls_page.update()


func _set_config_generic(value, name: String):
	if not _updating:
		_config.set(name, value)


func _set_screen_res_option(i: int):
	if _updating:
		return
	_ask_confirmation("screen_res")
	_config.screen_res = SCREEN_RES_ITEMS[i].value
	screen_res_option.grab_focus()


func _set_fullscreen(fullscreen: bool):
	if _updating:
		return
	_ask_confirmation("fullscreen")
	_config.fullscreen = fullscreen


func _set_master_vol(vol: float):
	master_vol_indicator.text = str(int(vol * 100.0))

	if not _updating:
		_config.master_vol = vol


func _set_music_vol(vol: float):
	music_vol_indicator.text = str(int(vol * 100.0))

	if not _updating:
		_config.music_vol = vol


func _set_sfx_vol(vol: float):
	sfx_vol_indicator.text = str(int(vol * 100.0))

	if not _updating:
		sfx_vol_test.play()
		_config.sfx_vol = vol


func _set_text_speed(text_speed: float):
	if _updating:
		return
	_config.text_speed = text_speed
	_update_text_speed_preview()


func _set_language(i: int):
	if _updating:
		return
	_config.locale = Constants.LOCALES.keys()[i]

	_push_warning("SETTINGS_LANG_CHANGED")


func _set_debug_playthrough(i: int):
	if _updating or not Utils.is_debug():
		return
	Game.playthrough = i + 1


func _update_text_speed_preview():
	text_speed_preview.text_speed_spk = _config.text_speed_spk


func _fade_aside_container(into: bool, child_idx: int):
	for i in range(aside_container.get_child_count()):
		aside_container.get_child(i).visible = i == child_idx

	var mod = Color.WHITE if into else Color.TRANSPARENT
	tween.stop_all()
	tween.interpolate_property(
		aside_container, "modulate", text_speed_preview.modulate, mod, 0.2
	)
	tween.start()


func _on_rhythm_offset_spinbox_focus_changed(focused: bool):
	_fade_aside_container(focused, 1)
	
	if focused:
		offset_calibrator.start()
	else:
		offset_calibrator.stop()


func _init_for_initial_settings():
	back_btn.text = "START"
	reset_btn.visible = false


func _show_credits():
	Game.save_config()
	Game.to_scene_key("credits", { "override_start_delay": 0.0 }, true)
