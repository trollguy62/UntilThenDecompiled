extends Label

signal completed

const LrcScript = preload("../../classes/lrc/LrcScript.gd")

@export_range(3.0, 1.0, 0.1) var final_line_grace_time: float = 5.0  #seconds
@export_range(0.0, 1.0, 0.01) var progress: float = 0.5:
	set(v):
		progress = clamp(v, 0.0, 1.0)
		_outline.progress = progress


@onready var _outline := $LyricsOutlined

var lrc_event: Dictionary = {}:
	set(v):
		_segment_time_start_msec = v["time_start"] * 1000
		_segment_time_end_msec = v["time_end"] * 1000
		lrc_event = v


var timestamp_msec: int = 0:
	set(v):
		progress = remap(v, _segment_time_start_msec, _segment_time_end_msec, 0.0, 1.0)
		if timestamp_msec >= _segment_time_end_msec && !_has_completed:
			_has_completed = true
			completed.emit()
		timestamp_msec = v


var lyric_text: String = "Lorem ipsum":
	set(v):
		text = v
		_outline.text = v
		lyric_text = v


var lrc_script: LrcScript:
	set(v):
		_reset()
		lrc_script = v
		_segment_time_start_msec = lrc_script.time_start * 1000.0
		_segment_time_end_msec = lrc_script.time_end * 1000.0
		if lrc_script.time_end < 0:
			_segment_time_end_msec = _segment_time_start_msec + final_line_grace_time * 1000.0

		self.lyric_text = lrc_script.text


var _segment_time_start_msec: int = 99999
var _segment_time_end_msec: int = 999999
var _has_completed = false


func is_active():
	return timestamp_msec > _segment_time_start_msec && timestamp_msec < _segment_time_end_msec


func _ready():
	_reset()


func _reset():
	self.progress = 0.0
	_has_completed = false
