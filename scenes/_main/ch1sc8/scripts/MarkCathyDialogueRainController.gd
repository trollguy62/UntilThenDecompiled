extends Node

@onready var mark_sprite = $"../SpriteMark"
@onready var cathy_sprite = $"../SpriteCathy"
@onready var combined_sprite = $"../SpriteCombined"

@onready var mark_sb = $"../SbPivotMarkBorja"
@onready var mark_alt_sb = $"../SbPivotMarkBorjaAlt"
@onready var cathy_sb = $"../SbPivotCathyPortillo"
@onready var cathy_alt_sb = $"../SbPivotCathyPortilloAlt"

@onready var mark_state = Utils.get_state_container_of("MarkBorja") as StateContainer


func _ready():
	mark_state.changed.connect(_on_mark_state_changed)


func _process(_delta):
	var mark_use_alt_sb = combined_sprite.animation in ["both_laugh"]
	var cathy_use_alt_sb = (
		combined_sprite.animation
		in ["both_laugh", "cathy_lean_trans", "cathy_lean"]
	)

	mark_sb.visible = not mark_use_alt_sb
	mark_alt_sb.visible = mark_use_alt_sb
	cathy_sb.visible = not cathy_use_alt_sb
	cathy_alt_sb.visible = cathy_use_alt_sb


func _on_mark_state_changed():
	var combined = mark_state.flags.has("combined")
	mark_sprite.visible = not combined
	cathy_sprite.visible = not combined
	combined_sprite.visible = combined
