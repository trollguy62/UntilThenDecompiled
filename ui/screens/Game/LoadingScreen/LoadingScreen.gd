extends CanvasLayer

@onready var ch_label = $UI/ChapterTransitionLabel
@onready var ch_anim_player = $UI/ChapterTransitionLabel/AnimationPlayer


func _ready():
	if Game.has_scene_param("chapter_text"):
		ch_label.text = Game.get_scene_param("chapter_text")
		ch_anim_player.play("Fade")
