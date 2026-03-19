extends CanvasLayer

const MB_TO_B = 1024.0 * 1024.0

@onready var root = $StatsMonitor
@onready var stats_simple = $StatsMonitor/Simple
@onready var stats_full = $StatsMonitor/Full

@onready var lbl_simple_fps = $StatsMonitor/Simple/VBox/LblFps
@onready var lbl_scene_id = $StatsMonitor/Simple/VBox/SceneId

@onready var vbox_engine = $StatsMonitor/Full/Engine/MarginContainer/VBoxEngine
@onready var vbox_3d = $StatsMonitor/Full/ThreeD/MarginContainer/VBox3D
@onready var vbox_fmod = $StatsMonitor/Full/Fmod/MarginContainer/VBoxFmod

@onready var lbl_fps = vbox_engine.get_node("LblFps")
@onready var lbl_process = vbox_engine.get_node("LblProcess")
@onready var lbl_physics_process = vbox_engine.get_node("LblPhysicsProcess")
@onready var lbl_engine_objects = vbox_engine.get_node("LblEngineObjects")
@onready var lbl_resources = vbox_engine.get_node("LblResources")
@onready var lbl_nodes = vbox_engine.get_node("LblNodes")

@onready var lbl_3d_objects = vbox_3d.get_node("Lbl3DObjects")
@onready var lbl_vertices = vbox_3d.get_node("LblVertices")
@onready var lbl_draw_calls = vbox_3d.get_node("LblDrawCalls")
@onready var lbl_video_memory = vbox_3d.get_node("LblVideoMem")
@onready var lbl_texture_memory = vbox_3d.get_node("LblTextureMem")
@onready var lbl_buffer_memory = vbox_3d.get_node("LblBufferMem")

@onready var lbl_audio_cpu = vbox_fmod.get_node("LblCpu")
@onready var lbl_audio_memory = vbox_fmod.get_node("LblMemory")


func _ready():
	root.visible = false
	set_process(false)


func _input(event):
	if event.is_action_pressed("stats_monitor"):
		if not root.visible:
			root.visible = true
			stats_simple.visible = true
			stats_full.visible = false
			set_process(true)
		elif stats_simple.visible:
			stats_simple.visible = false
			stats_full.visible = true
		elif stats_full.visible:
			root.visible = false
			set_process(false)


func set_scene_id_label(scene_id):
	lbl_scene_id.text = scene_id


func _process(delta):
	if stats_simple.is_visible_in_tree():
		_update_stats_simple()
	elif stats_full.is_visible_in_tree():
		_update_stats_full()


func _update_stats_simple():
	lbl_simple_fps.text = "FPS: %d" % Performance.get_monitor(Performance.TIME_FPS)


func _update_stats_full():
	# ENGINE
	lbl_fps.text = "FPS: %d" % Performance.get_monitor(Performance.TIME_FPS)
	lbl_process.text = (
		"Process: %.4fms"
		% [Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0]
	)
	lbl_physics_process.text = (
		"PhysProcess: %.4fms"
		% [Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0]
	)
	lbl_engine_objects.text = "Objects: %d" % Performance.get_monitor(Performance.OBJECT_COUNT)
	lbl_resources.text = (
		"Resources: %d"
		% Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT)
	)
	lbl_nodes.text = "Nodes: %d" % Performance.get_monitor(Performance.OBJECT_NODE_COUNT)

	# 3D
	lbl_3d_objects.text = (
		"Objects: %d"
		% Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)
	)
	lbl_vertices.text = (
		"Vertices: %d"
		% Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)
	)
	lbl_draw_calls.text = (
		"DrawCalls: %d"
		% Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
	)
	lbl_video_memory.text = (
		"VideoMem: %.2fMB"
		% (Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / MB_TO_B)
	)
	lbl_texture_memory.text = (
		"TextureMem: %.2fMB"
		% (Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED) / MB_TO_B)
	)
	lbl_buffer_memory.text = (
		"BufferMem: %.2fMB"
		% (Performance.get_monitor(Performance.RENDER_BUFFER_MEM_USED) / MB_TO_B)
	)

	# FMOD
	if Utils.is_internal_debug():
		$StatsMonitor/Full/Fmod.show()
		lbl_audio_cpu.text = (
			"CPU: dsp = %.3f%%, studio = %.3f%%"
			% [
				Performance.get_custom_monitor("FMOD/DSP CPU Usage (%)"),
				Performance.get_custom_monitor("FMOD/Studio CPU Update (%)")
			]
		)
		lbl_audio_memory.text = (
			"MEMORY: cur = %.2fMB, max = %.2fMB"
			% [
				Performance.get_custom_monitor("FMOD/Memory Allocation (MB)"),
				Performance.get_custom_monitor("FMOD/Max Memory Allocation (MB)")
			]
		)
