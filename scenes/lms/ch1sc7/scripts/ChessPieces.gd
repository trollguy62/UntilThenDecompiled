@tool
extends Node3D

@export_multiline var fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"
@export var cell_size := 0.1
@export_range(0.0, 360.0) var piece_rotation := 0
@export_range(0.0, 180.0) var random_rotation := 0
@export var generate := false

@export var black_piece_color: Color = Color("#616161")
@export var white_piece_color: Color = Color.WHITE

@export var piece_queen: Texture
@export var piece_king: Texture
@export var piece_bishop: Texture
@export var piece_knight: Texture
@export var piece_rook: Texture
@export var piece_pawn: Texture

enum ChessPieceType { QUEEN, KING, BISHOP, KNIGHT, ROOK, PAWN }

const PIECE_CHAR_TYPE_MAP := {
	"q": ChessPieceType.QUEEN,
	"k": ChessPieceType.KING,
	"b": ChessPieceType.BISHOP,
	"n": ChessPieceType.KNIGHT,
	"r": ChessPieceType.ROOK,
	"p": ChessPieceType.PAWN
}


func _process(_delta):
	if Engine.is_editor_hint() and generate:
		_clear()
		_gen_config()


func _clear():
	for child in get_children():
		child.queue_free()
		remove_child(child)


func _gen_config():
	var b = _parse_fen()
	var piece_texture_map = {
		ChessPieceType.QUEEN: piece_queen,
		ChessPieceType.KING: piece_king,
		ChessPieceType.BISHOP: piece_bishop,
		ChessPieceType.KNIGHT: piece_knight,
		ChessPieceType.ROOK: piece_rook,
		ChessPieceType.PAWN: piece_pawn
	}

	for y in range(8):
		for x in range(8):
			var piece = b[y][x]
			if piece == null:
				continue

			var pos = Vector3(cell_size * x, 0, cell_size * (y + 0.5))
			var sprite = Paper3D.new()
			var texture: Texture = piece_texture_map[piece.type]
			var rand_rot := randf_range(-random_rotation, random_rotation)

			pos.x += cell_size / 2.0
			pos.y += (texture.get_height() * sprite.pixel_size) / 2.0

			sprite.position = pos
			sprite.texture = texture
			sprite.modulate = white_piece_color if piece.white else black_piece_color
			sprite.rotation_degrees.y = piece_rotation + rand_rot
			sprite.centered = true
			sprite.use_in_baked_light = true
			sprite.flip_h = randf() < 0.5

			add_child(sprite)
			sprite.owner = get_tree().edited_scene_root
			sprite.set_script(null)


func _parse_fen() -> Array:
	var b = []
	var r = []

	for c in fen:
		var piece_type = PIECE_CHAR_TYPE_MAP.get(c.to_lower())

		if piece_type != null:
			var white = _is_uppercase(c)
			r.append(ChessPiece.new(piece_type, white))
		elif c == "/":
			b.append(r)
			r = []
		elif c in "0123456789":
			for _i in range(int(c)):
				r.append(null)
		else:
			break

	b.append(r)
	return b


func _is_uppercase(c: String) -> bool:
	var o = c.to_ascii_buffer()[0]
	return o >= 65 and o <= 90


class ChessPiece:
	var type: int
	var white: bool

	func _init(type: int, white: bool):
		self.type = type
		self.white = white
