extends Node

const PARAM_TIME_SCALE = "game_time_scale"

#@onready var bus_master := FMODStudioModule.get_studio_system().get_bus("bus:/")
#@onready var bus_music := FMODStudioModule.get_studio_system().get_bus("bus:/Music")
#@onready var bus_sfx := FMODStudioModule.get_studio_system().get_bus("bus:/SFX")
var bus_master: Bus
var bus_music: Bus
var bus_sfx: Bus

@onready var listener_2d := StudioListener2D.new()
@onready var listener_3d := StudioListener3D.new()


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	bus_master = FMODStudioModule.get_studio_system().get_bus("bus:/")
	bus_music = FMODStudioModule.get_studio_system().get_bus("bus:/Music")
	bus_sfx = FMODStudioModule.get_studio_system().get_bus("bus:/SFX")

	add_child(listener_2d)
	add_child(listener_3d)

func _process(delta):
	_sync_listeners()

	_sync_bus_volume(bus_master, Constants.BUS_IDX_MASTER)
	_sync_bus_volume(bus_music, Constants.BUS_IDX_MUSIC)
	_sync_bus_volume(bus_sfx, Constants.BUS_IDX_SFX)

	bus_master.set_paused(Game.paused)

	FMODStudioModule.get_studio_system().set_parameter_by_name(
		PARAM_TIME_SCALE,
		Engine.time_scale if Game.config.debug_time_scaled_audio else 1.0,
		false
	)

	FMODStudioModule.get_studio_system().update()


func _sync_listeners():
	var global_transform_2d = Transform2D.IDENTITY
	var global_transform_3d = Transform3D.IDENTITY

	var viewport = get_viewport()
	var camera_2d = viewport.get_camera_2d()
	var camera_3d = viewport.get_camera_3d()

	if camera_2d != null:
		global_transform_2d = camera_2d.global_transform

	if camera_3d != null:
		global_transform_3d = camera_3d.global_transform

	listener_2d.global_transform = global_transform_2d
	listener_3d.global_transform = global_transform_3d


func _sync_bus_volume(bus: Bus, godot_bus_idx: int):
	var volume := db_to_linear(AudioServer.get_bus_volume_db(godot_bus_idx))
	var mute := AudioServer.is_bus_mute(godot_bus_idx)

	bus.set_volume(volume)
	bus.set_mute(mute)
