extends "../Screen.gd"

const FbStatus = preload("res://data/fb/FbStatus.gd")

@onready var video_player = $CoolVideoPlayer
@onready var stats_bar = $FbMediaStatsBar

var status: FbStatus


func _ready():
	assert(status.content_type == FbStatus.CONTENT_TYPE_VIDEO)

	stats_bar.atom = status
	video_player.fullscreen_toggled.connect(_on_fullscreen_toggled)

	video_player.video_ref = status.content
	video_player.size = Utils.cover_aspect_size(video_player.video_size, size)
	video_player.position = (size - video_player.size) / 2


func _on_fullscreen_toggled():
	navigator.pop()
