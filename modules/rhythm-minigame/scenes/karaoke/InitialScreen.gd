extends Control

const KaraokeSong = preload("./KaraokeSong.gd")

var current_song: KaraokeSong:
	set(v):
		if !is_inside_tree():
			await self.ready

		$SongTitle.text = v.title
		if v.artist:
			$Artist.text = tr("MG_KARAOKE_ARTIST") % v.artist
		else:
			$Artist.text = v.artist

		current_song = v
