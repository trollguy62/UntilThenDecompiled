extends Node

signal offset_suggested(offset_ms: int)

@export_range(10.0, 300.0) var bpm := 120.0

@onready var sfx_clap := $Clap

var _running := false
var _spb := 0.0
var _t := 0.0
var _beat := 0
var _beat_latency := 0.0

var _avg_offset := 0.0
var _samples := 0

func _ready():
	_spb = 60.0 / bpm
	assert(_spb > 0)


func _physics_process(delta: float):
	if not _running:
		return
	
	_t += delta
	
	while _t >= _spb or _beat == -1:
		if _beat == -1:
			_t = 0.0
			_beat = 0
		else:
			_t -= _spb
			_beat = (_beat + 1) % 4
		
		sfx_clap.play()
		_beat_latency = _get_audio_latency_hw() + _t


func start():
	_avg_offset = 0.0
	_samples = 0
	_beat = -1 # start on next physics tick
	_running = true


func stop():
	_running = false


func trigger():
	if not _running:
		return
	
	var tc := _t - fmod(_beat_latency, _spb)
	var delta := tc - _spb if tc >= _spb / 2.0 else tc
	var offset := -delta * 1000.0
	
	if _samples > 1:
		_avg_offset -= _avg_offset / _samples
		_avg_offset += offset / _samples
	elif _samples == 1:
		_avg_offset = (_avg_offset + offset) / 2.0
	else:
		_avg_offset = offset

	_samples += 1
	
	if _samples >= 3:
		offset_suggested.emit(roundi(_avg_offset))


func _get_audio_latency_hw() -> float:
	return AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
