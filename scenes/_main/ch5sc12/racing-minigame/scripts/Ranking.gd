extends TextureRect

@export var ranking_textures : Array[Texture]


func set_rank(rank):
	texture = ranking_textures[rank - 1]
