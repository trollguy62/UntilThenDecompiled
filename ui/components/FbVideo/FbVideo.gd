extends PanelContainer

const FbStatus = preload("res://data/fb/FbStatus.gd")

@onready var video_player = $CoolVideoPlayer

var status: FbStatus


func _ready():
	assert(status.content_type == FbStatus.CONTENT_TYPE_VIDEO)

	video_player.video_ref = status.content
	video_player.fullscreen_toggled.connect(_on_fullscreen_toggled)

	await get_tree().process_frame
	var video_size = video_player.video_size
	custom_minimum_size.y = video_size.y * (size.x / video_size.x)


func _on_fullscreen_toggled():
	var navigator = Service.of(Service.NAVIGATOR)
	if navigator:
		navigator.push_named("fb://video", {"status": status})
		video_player.paused = true
