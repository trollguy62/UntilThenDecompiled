extends CanvasLayer

@onready var flash = $ColorRect
@onready var animation_player = $AnimationPlayer


func _on_mole_hit(score):
	screen_flash(score)

func screen_flash(score):
	if score > 0:
		animation_player.play("flash")
	else:
		animation_player.play("flash_red")
