extends Resource

const Keybind = preload("res://data/Keybind.gd")

signal text_speed_changed()
signal hide_props_changed()
signal locale_changed(locale: String)
signal remapped(action: String, ev: InputEventKey)
signal debug_unlock_all_scenes_changed()
signal rhythm_settings_changed()

const TARGET_VERSION := 2
const TIME_SCALE_VERY_SLOW_V1 := 0.25
const TIME_SCALE_VERY_SLOW_V2 := 0.2

const TEXT_SPEED_SPK_MIN := 0.01
const TEXT_SPEED_SPK_MAX := 0.11
const TEXT_SPEED_DELAY_MULT_MIN := 0.5
const TEXT_SPEED_DELAY_MULT_MAX := 1.25

const SHADOW_ATLAS_SIZE := 4096

const PATH = "user://settings.res"

var _prop_def_aa := {
	"presets": [
		{"name": "SETTINGS_OFF"},
		{"name": "FXAA", "ssaa": Viewport.SCREEN_SPACE_AA_FXAA},
		{"name": "TAA", "taa": true},
		{"name": "MSAA 2x", "msaa": Viewport.MSAA_2X, "default": true},
		{"name": "MSAA 4x", "msaa": Viewport.MSAA_4X},
		{"name": "MSAA 8x", "msaa": Viewport.MSAA_8X}
	],
	"setter": func(idx: int, preset: Dictionary):
		var msaa = preset.get("msaa", Viewport.MSAA_DISABLED)
		var ssaa = preset.get("ssaa", Viewport.SCREEN_SPACE_AA_DISABLED)
		var taa = preset.get("taa", false)

		_viewport.msaa_2d = msaa
		_viewport.msaa_3d = msaa
		_viewport.screen_space_aa = ssaa
		_viewport.use_taa = taa
}

var _prop_def_volumetrics := {
	"presets": [
		{"name": "SETTINGS_OFF", "gr_samples": 0, "size": 0, "depth": 0},
		{"name": "SETTINGS_VERY_LOW", "gr_samples": 15, "size": 48, "depth": 48},
		{"name": "SETTINGS_LOW", "gr_samples": 30, "size": 56, "depth": 56},
		{"name": "SETTINGS_MEDIUM", "gr_samples": 40, "filter": true, "size": 64, "depth": 64, "default": true},
		{"name": "SETTINGS_HIGH", "gr_samples": 50, "filter": true, "size": 68, "depth": 68},
		{"name": "SETTINGS_ULTRA", "gr_samples": 50, "gr_pcf5": true, "filter": true, "size": 72, "depth": 72}
	],
	"setter": func(idx: int, preset: Dictionary):
		ProjectSettings.set_setting("rendering/quality/godrays/use_pcf5", preset.get("gr_pcf5", false))
		ProjectSettings.set_setting("rendering/quality/godrays/sample_number", preset.gr_samples)

		var disable_fog = preset.size == 0 or preset.depth == 0
		EnvironmentManager.disable_volumetric_fog = disable_fog

		if not disable_fog:
			RenderingServer.environment_set_volumetric_fog_filter_active(preset.get("filter", false))
			RenderingServer.environment_set_volumetric_fog_volume_size(preset.size, preset.depth)
}

var _prop_def_fsr := {
	"presets": [
		{"name": "SETTINGS_OFF", "scale": 0.0, "sharpness": 0.0, "default": true},
		{"name": "Quality", "scale": 0.7, "sharpness": 1.5},
		{"name": "Balanced", "scale": 0.6, "sharpness": 1.5},
		{"name": "Performance", "scale": 0.5, "sharpness": 1.5}
	],
	"setter": func(idx: int, preset: Dictionary):
		_update_screen()
}

var _prop_def_gi_quality := {
	"presets": [
		{"name": "SETTINGS_OFF", "quality": RenderingServer.VOXEL_GI_QUALITY_LOW, "half_res": true, "disable": true},
		{"name": "SETTINGS_LOW", "quality": RenderingServer.VOXEL_GI_QUALITY_LOW, "half_res": true},
		{"name": "SETTINGS_MEDIUM", "quality": RenderingServer.VOXEL_GI_QUALITY_LOW, "half_res": false, "default": true},
		{"name": "SETTINGS_HIGH", "quality": RenderingServer.VOXEL_GI_QUALITY_HIGH, "half_res": false}
	],
	"setter": func(idx: int, preset: Dictionary):
		EnvironmentManager.disable_gi = preset.get("disable", false)
		RenderingServer.voxel_gi_set_quality(preset.quality)
		RenderingServer.gi_set_use_half_resolution(preset.half_res)
}

var _prop_def_glow_quality := {
	"presets": [
		{"name": "SETTINGS_OFF", "bicubic": false, "disable": true},
		{"name": "SETTINGS_LOW", "bicubic": false},
		{"name": "SETTINGS_HIGH", "bicubic": true, "default": true}
	],
	"setter": func(idx: int, preset: Dictionary):
		EnvironmentManager.disable_glow = preset.get("disable", false)
		RenderingServer.environment_glow_set_use_bicubic_upscale(preset.bicubic)
}

var _prop_def_shadow_quality := {
	"presets": [
		{"name": "SETTINGS_OFF", "quality": RenderingServer.SHADOW_QUALITY_HARD, "disable": true},
		{"name": "SETTINGS_VERY_LOW", "quality": RenderingServer.SHADOW_QUALITY_HARD},
		{"name": "SETTINGS_LOW", "quality": RenderingServer.SHADOW_QUALITY_SOFT_VERY_LOW},
		{"name": "SETTINGS_MEDIUM", "quality": RenderingServer.SHADOW_QUALITY_SOFT_LOW, "default": true},
		{"name": "SETTINGS_HIGH", "quality": RenderingServer.SHADOW_QUALITY_SOFT_MEDIUM},
		{"name": "SETTINGS_ULTRA", "quality": RenderingServer.SHADOW_QUALITY_SOFT_HIGH}
	],
	"setter": func(idx: int, preset: Dictionary):
		var disable = preset.get("disable", false)
		RenderingServer.directional_shadow_atlas_set_size(1 if disable else SHADOW_ATLAS_SIZE, true)
		RenderingServer.directional_soft_shadow_filter_set_quality(preset.quality)
		RenderingServer.positional_soft_shadow_filter_set_quality(preset.quality)
}

var _prop_def_bokeh_quality := {
	"presets": [
		{"name": "SETTINGS_OFF", "quality": RenderingServer.DOF_BLUR_QUALITY_VERY_LOW, "shape": RenderingServer.DOF_BOKEH_BOX, "disable": true},
		{"name": "SETTINGS_VERY_LOW", "quality": RenderingServer.DOF_BLUR_QUALITY_VERY_LOW, "shape": RenderingServer.DOF_BOKEH_BOX},
		{"name": "SETTINGS_LOW", "quality": RenderingServer.DOF_BLUR_QUALITY_VERY_LOW},
		{"name": "SETTINGS_MEDIUM", "quality": RenderingServer.DOF_BLUR_QUALITY_LOW, "default": true},
		{"name": "SETTINGS_HIGH", "quality": RenderingServer.DOF_BLUR_QUALITY_MEDIUM},
		{"name": "SETTINGS_ULTRA", "quality": RenderingServer.DOF_BLUR_QUALITY_HIGH}
	],
	"setter": func(idx: int, preset: Dictionary):
		EnvironmentManager.disable_bokeh = preset.get("disable", false)
		RenderingServer.camera_attributes_set_dof_blur_quality(preset.quality, false)
		RenderingServer.camera_attributes_set_dof_blur_bokeh_shape(preset.get("shape", RenderingServer.DOF_BOKEH_CIRCLE))
}

var _prop_def_reflections_quality := {
	"presets": [
		{"name": "SETTINGS_OFF", "quality": RenderingServer.ENV_SSR_ROUGHNESS_QUALITY_DISABLED, "limiter": false, "disable": true},
		{"name": "SETTINGS_VERY_LOW", "quality": RenderingServer.ENV_SSR_ROUGHNESS_QUALITY_DISABLED, "limiter": false},
		{"name": "SETTINGS_LOW", "quality": RenderingServer.ENV_SSR_ROUGHNESS_QUALITY_DISABLED},
		{"name": "SETTINGS_MEDIUM", "quality": RenderingServer.ENV_SSR_ROUGHNESS_QUALITY_LOW, "default": true},
		{"name": "SETTINGS_HIGH", "quality": RenderingServer.ENV_SSR_ROUGHNESS_QUALITY_MEDIUM},
		{"name": "SETTINGS_ULTRA", "quality": RenderingServer.ENV_SSR_ROUGHNESS_QUALITY_HIGH}
	],
	"setter": func(idx: int, preset: Dictionary):
		EnvironmentManager.disable_reflections = preset.get("disable", false)
		RenderingServer.environment_set_ssr_roughness_quality(preset.quality)
		RenderingServer.screen_space_roughness_limiter_set_active(
			preset.get("limiter", true),
			ProjectSettings.get_setting("rendering/anti_aliasing/screen_space_roughness_limiter/amount"),
			ProjectSettings.get_setting("rendering/anti_aliasing/screen_space_roughness_limiter/limit")
		)
}

var _prop_def_ssao_quality := {
	"presets": [
		{"name": "SETTINGS_OFF", "quality": RenderingServer.ENV_SSAO_QUALITY_VERY_LOW, "half_size": true, "disable": true},
		{"name": "SETTINGS_VERY_LOW", "quality": RenderingServer.ENV_SSAO_QUALITY_VERY_LOW, "half_size": true},
		{"name": "SETTINGS_LOW", "quality": RenderingServer.ENV_SSAO_QUALITY_LOW},
		{"name": "SETTINGS_MEDIUM", "quality": RenderingServer.ENV_SSAO_QUALITY_MEDIUM, "default": true},
		{"name": "SETTINGS_HIGH", "quality": RenderingServer.ENV_SSAO_QUALITY_HIGH},
		{"name": "SETTINGS_ULTRA", "quality": RenderingServer.ENV_SSAO_QUALITY_ULTRA, "adaptive_target": 1.0}
	],
	"setter": func(idx: int, preset: Dictionary):
		EnvironmentManager.disable_ssao = preset.get("disable", false)
		RenderingServer.environment_set_ssao_quality(
			preset.quality,
			preset.get("half_size", false),
			preset.get("adaptive_target", ProjectSettings.get_setting("rendering/environment/ssao/adaptive_target")),
			ProjectSettings.get_setting("rendering/environment/ssao/blur_passes"),
			ProjectSettings.get_setting("rendering/environment/ssao/fadeout_from"),
			ProjectSettings.get_setting("rendering/environment/ssao/fadeout_to")
		)
}

@export var version := TARGET_VERSION

@export var screen_res := Vector2i(1280, 720):
	set(value):
		screen_res = value
		if _is_setup:
			_update_screen()

@export var fullscreen := false:
	set(value):
		fullscreen = value
		if _is_setup:
			_update_screen()

@export var aa: int = -1:
	set(value):
		aa = value
		_set_prop(value, _prop_def_aa)
	get:
		return _get_prop(aa, _prop_def_aa)

@export var fsr: int = -1:
	set(value):
		fsr = value
		_set_prop(value, _prop_def_fsr)
	get:
		return _get_prop(fsr, _prop_def_fsr)

@export var volumetrics: int = -1:
	set(value):
		volumetrics = value
		_set_prop(value, _prop_def_volumetrics)
	get:
		return _get_prop(volumetrics, _prop_def_volumetrics)

@export var gi_quality: int = -1:
	set(value):
		gi_quality = value
		_set_prop(value, _prop_def_gi_quality)
	get:
		return _get_prop(gi_quality, _prop_def_gi_quality)

@export var glow_quality: int = -1:
	set(value):
		glow_quality = value
		_set_prop(value, _prop_def_glow_quality)
	get:
		return _get_prop(glow_quality, _prop_def_glow_quality)

@export var shadow_quality: int = -1:
	set(value):
		shadow_quality = value
		_set_prop(value, _prop_def_shadow_quality)
		if _is_setup:
			_viewport.positional_shadow_atlas_size = 0 if value <= 0 else SHADOW_ATLAS_SIZE
	get:
		return _get_prop(shadow_quality, _prop_def_shadow_quality)

@export var bokeh_quality: int = -1:
	set(value):
		bokeh_quality = value
		_set_prop(value, _prop_def_bokeh_quality)
	get:
		return _get_prop(bokeh_quality, _prop_def_bokeh_quality)

@export var reflections_quality: int = -1:
	set(value):
		reflections_quality = value
		_set_prop(value, _prop_def_reflections_quality)
	get:
		return _get_prop(reflections_quality, _prop_def_reflections_quality)

@export var ssao_quality: int = -1:
	set(value):
		ssao_quality = value
		_set_prop(value, _prop_def_ssao_quality)
	get:
		return _get_prop(ssao_quality, _prop_def_ssao_quality)

@export var debanding := true:
	set(value):
		debanding = value
		if _is_setup:
			_viewport.use_debanding = debanding

@export_range(0.0, 1.0) var master_vol = 1.0:
	set(value):
		master_vol = value
		if _is_setup:
			_set_bus_vol(Constants.BUS_IDX_MASTER, value)

@export_range(0.0, 1.0) var music_vol := 1.0:
	set(value):
		music_vol = value
		if _is_setup:
			_set_bus_vol(Constants.BUS_IDX_MUSIC, value)

@export_range(0.0, 1.0) var sfx_vol: float = 1.0:
	set(value):
		sfx_vol = value
		if _is_setup:
			_set_bus_vol(Constants.BUS_IDX_SFX, value)

@export_range(0.0, 1.0) var text_speed := 0.85:
	set(value):
		text_speed = value
		if _is_setup:
			text_speed_changed.emit()

@export var locale := Constants.DEFAULT_LOCALE:
	set(value):
		locale = value
		if _is_setup:
			TranslationServer.set_locale(locale)
			locale_changed.emit(locale)

@export var skip_content_warning := false

@export_range(-1000, 1000) var rhythm_offset_ms: int = 0:
	set(value):
		rhythm_offset_ms = value
		if _is_setup:
			rhythm_settings_changed.emit()

@export_range(0.5, 3.0, 0.1) var rhythm_lane_speed_mult := 1.0:
	set(value):
		rhythm_lane_speed_mult = value
		if _is_setup:
			rhythm_settings_changed.emit()

@export var input: Dictionary = {}

var text_speed_spk: float:
	get: # Seconds per keystroke
		return lerp(TEXT_SPEED_SPK_MAX, TEXT_SPEED_SPK_MIN, text_speed) \
				/ (0.55 if is_locale_non_latin() else 1)

var text_speed_kps: float:
	get:
		return 1.0 / self.text_speed_spk  # Keystrokes per second

var text_speed_delay_mult: float:
	get:
		return lerp(TEXT_SPEED_DELAY_MULT_MAX, TEXT_SPEED_DELAY_MULT_MIN, text_speed) # Keystrokes per second

@export var enable_time_scale_controls := true
@export var time_scale_very_slow := TIME_SCALE_VERY_SLOW_V2
@export var time_scale_slow := 0.5
@export var time_scale_fast := 2.5
@export var time_scale_very_fast := 25.0

@export var hide_cursor := false:
	set(value):
		hide_cursor = value
		if not _is_setup:
			return

		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN if hide_cursor else Input.MOUSE_MODE_VISIBLE)

@export var hide_ingame_ui := false:
	set(value):
		hide_ingame_ui = value
		if _is_setup:
			hide_props_changed.emit()

@export var hide_bubbles := false:
	set(value):
		hide_bubbles = value
		if _is_setup:
			hide_props_changed.emit()

@export var hide_phone := false:
	set(value):
		hide_phone = value
		if _is_setup:
			hide_props_changed.emit()

@export var hide_player := false:
	set(value):
		hide_player = value
		if _is_setup:
			hide_props_changed.emit()

@export var hide_story_chars := false:
	set(value):
		hide_story_chars = value
		if _is_setup:
			hide_props_changed.emit()

@export var hide_npcs := false:
	set(value):
		hide_npcs = value
		if _is_setup:
			hide_props_changed.emit()

@export var debug_unlock_all_scenes := false:
	set(value):
		debug_unlock_all_scenes = value
		if _is_setup:
			debug_unlock_all_scenes_changed.emit()

@export var debug_fmod_live_update := false
@export var debug_time_scaled_audio := false

var _is_setup := false
var _viewport: Window


# Returns `true` if values have been changed due to migration and should be saved by caller
func setup(viewport: Window) -> bool:
	assert(viewport != null)
	var did_migrate = false

	# Since `version` didn't exist before v1.3, this is how we deal with it ¯\_(ツ)_/¯
	if version > 1 and Utils.equals(time_scale_very_slow, TIME_SCALE_VERY_SLOW_V1):
		version = 1
		time_scale_very_slow = TIME_SCALE_VERY_SLOW_V2

	if version < TARGET_VERSION:
		_migrate()
		did_migrate = true

	_viewport = viewport
	_is_setup = true
	return did_migrate


func _migrate():
	print("SettingsConfig is version %d. Migrating to version %d..." % [version, TARGET_VERSION])

	for from_ver in range(version, TARGET_VERSION):
		match from_ver:
			1: # 1 -> 2: Bump enums that got a new "Off" option
				gi_quality += 1
				glow_quality += 1
				shadow_quality += 1
				bokeh_quality += 1
			2: # 2 -> 3: (placeholder)
				pass

		print("SettingsConfig migrated to version %d" % (from_ver + 1))

	version = TARGET_VERSION


func apply():
	self.aa = aa
	self.volumetrics = volumetrics
	self.gi_quality = gi_quality
	self.glow_quality = glow_quality
	self.shadow_quality = shadow_quality
	self.bokeh_quality = bokeh_quality
	self.reflections_quality = reflections_quality
	self.ssao_quality = ssao_quality
	self.debanding = debanding

	self.master_vol = master_vol
	self.music_vol = music_vol
	self.sfx_vol = sfx_vol
	self.hide_cursor = hide_cursor
	self.locale = locale

	_update_screen()


func _set_prop(idx: int, prop_def: Dictionary):
	if _is_setup:
		var setting = prop_def.presets[idx]
		prop_def.setter.call(idx, setting)


func _get_prop(idx: int, prop_def: Dictionary) -> int:
	var presets_count = prop_def.presets.size()

	if idx >= 0 and idx < presets_count:
		return idx
	else:
		for i in range(presets_count):
			var preset = prop_def.presets[i]
			if preset.get("default", false):
				return i
	# No explicit default found, use first preset
	return 0


func get_prop_preset_names(name: String) -> Array:
	var prop_def = get("_prop_def_" + name)
	return prop_def.presets.map(func(preset): return preset.name)


func is_locale_non_latin() -> bool:
	return locale in ["ja", "zh-CN"]


func _update_screen():
	var fsr_preset = _prop_def_fsr.presets[self.fsr]
	# This doesn't work reliably. We're ditching FSR.
	var fsr_enabled = false # fsr_preset.scale > 0.0

	_viewport.mode = Window.MODE_EXCLUSIVE_FULLSCREEN if fullscreen else Window.MODE_WINDOWED
	_viewport.scaling_3d_mode = \
			Viewport.SCALING_3D_MODE_FSR if fsr_enabled else Viewport.SCALING_3D_MODE_BILINEAR

	if fullscreen:
		var screen_size = DisplayServer.screen_get_size(_viewport.current_screen)
		var scale = Vector2(screen_res) / Vector2(screen_size)
		_viewport.scaling_3d_scale = max(scale.x, scale.y)
	else:
		_viewport.scaling_3d_scale = 1.0
		_viewport.size = screen_res

	if fsr_enabled:
		_viewport.scaling_3d_scale *= fsr_preset.scale
		_viewport.fsr_sharpness = fsr_preset.sharpness


func _set_bus_vol(bus_idx: int, vol: float):
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(vol))
