extends Container

@export var animation_time: float = 3.0
@export var refresh_interval: float = 10.0  #s
var songs: Array = []

@onready var _tween := Threen.new()
@onready var _container := $HBoxContainer
@onready var _song_container := $HBoxContainer/HBoxContainer/VBoxContainer
@onready var _refresh_timer := $RefreshInterval
@onready var _preview = $HBoxContainer/HBoxContainer/VBoxContainer/Preview


func _ready():
	add_child(_tween)
	_refresh_timer.timeout.connect(show)
	_song_container.remove_child(_preview)


#override
func show():
	_clear_previews()
	_generate_previews()
	var target_height = _get_height()
	_tween.interpolate_property(
		self,
		"size",
		Vector2(size.x, 0),
		Vector2(size.x, target_height),
		animation_time,
		_tween.TRANS_LINEAR
	)
	_tween.start()
	visible = true
	_refresh_timer.start(refresh_interval)


#override
func hide():
	_refresh_timer.stop()
	visible = false


func _clear_previews():
	for n in _song_container.get_children():
		n.queue_free()


func _generate_previews():
	var previews: Array = []  #Array of Labels
	for song in songs:
		var p = _preview.duplicate()
		p.text = str(song.id) + " - " + song.title
		previews.push_back(p)

	previews.shuffle()
	for p in previews:
		_song_container.add_child(p)


func _get_height() -> float:
	return _container.size.y
