extends RefCounted

var id: int = -1
var title: String
var artist: String
var map_file_path: String
var lrc_file_path: String


func _init(
	title_: String, artist_: String = "", id_ = -1, map_file_path_ = "", lrc_file_path_ = ""
):
	title = title_
	artist = artist_
	id = id_
	map_file_path = map_file_path_
	lrc_file_path = lrc_file_path_
