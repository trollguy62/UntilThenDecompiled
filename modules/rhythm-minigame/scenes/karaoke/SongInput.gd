extends HBoxContainer

const KaraokeSong = preload("./KaraokeSong.gd")

@export var hide_delay: float = 2.0  #s

@onready var label = $SongInfoMinimal

var song: KaraokeSong:
	set(v):
		label.text = str(v.id).pad_zeros(4) + " - " + v.title
		song = v


func reset():
	label.text = str(0).pad_zeros(4) + "- " + tr("MG_KARAOKE_NO_SONG")
	hide()
