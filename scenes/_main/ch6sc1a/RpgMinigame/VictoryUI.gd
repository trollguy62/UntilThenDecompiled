extends Control

signal finished


func play_animation(winner = null):
	if winner:
		if "hp" in winner:
			$P1_HP.hp = winner.hp
		if "player_name" in winner:
			$P1_HP.player_name = winner.player_name
	$AnimationPlayer.play("enter")
	await $AnimationPlayer.animation_finished
	emit_signal("finished")
