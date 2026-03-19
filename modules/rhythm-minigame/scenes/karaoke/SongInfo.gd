extends VBoxContainer

const KaraokeSong = preload("./KaraokeSong.gd")

@onready var title_label = $SongTitle
@onready var artist_label = $Artist
@onready var id_label = $SongId


func set_song(song: KaraokeSong):
	title_label.text = song.title
	artist_label.text = song.artist
	id_label.text = str(song.id).pad_zeros(4)


func reset():
	title_label.text = "MG_KARAOKE_NO_SONG"
	id_label.text = "0000"
