extends HBoxContainer

signal queue_changed

const KaraokeSong = preload("./KaraokeSong.gd")

@onready var song_number_node = $SongNumber

var song_queue: Array = []


func _ready():
	assert(song_number_node)
	remove_child(song_number_node)


func queue(song: KaraokeSong):
	song_queue.push_back(song)
	var new = song_number_node.duplicate()
	new.text = str(song.id).pad_zeros(4)
	add_child(new)
	queue_changed.emit()


func dequeue() -> KaraokeSong:
	#FIXME
	if song_queue.is_empty():
		return null
	##
	var song = song_queue.pop_front()
	get_child(0).queue_free()
	queue_changed.emit()
	return song


func is_empty() -> bool:
	return song_queue.is_empty()
