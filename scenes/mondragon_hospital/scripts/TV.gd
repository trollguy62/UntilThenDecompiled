extends Node3D

@onready var display = $Panel/Display
@onready var display_mat = display.material_override as ShaderMaterial

@onready var tv_typhoon = $SFX/TvTyphoon
@onready var tv_weather_report = $SFX/TvWeatherReport
@onready var tv_static = $SFX/TvStatic


func _process(delta):
	var non_static_vol = 1.0
	var static_vol = 0.0

	if display_mat.get_shader_parameter("static_blend") > 0.9:
		non_static_vol = 0.0
		static_vol = 1.0

	tv_typhoon.volume = non_static_vol
	tv_weather_report.volume = non_static_vol
	tv_static.volume = static_vol
