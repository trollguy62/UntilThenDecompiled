extends Control

@onready var anim = $AnimationPlayer
@onready var rank_label = $Ranking
@onready var lap_label = $VBoxContainer/Laps
@onready var timer_label = $VBoxContainer/Time
@onready var wrongway_label = $WrongWay/Label
@onready var timeout_label = $Timeout/Label
@onready var finish_label = $Finish/Label
@onready var km_label = $Tachometer/KmLabel
@onready var rpm_arrow: TextureRect = $Tachometer/ArrowMeter


func _ready():
	wrongway_label.visible = false
	timeout_label.visible = false
	finish_label.visible = false


func set_lap_display(lap, total_laps):
	lap_label.text = "LAPS :" + "  " + str(lap) + "/" + str(total_laps)


func _on_countdown_display(timer):
	anim.play("Countdown")


func _on_rank_changed(rank):
	rank_label.set_rank(rank)


func _on_lap_completed(lap, total_laps):
	set_lap_display(lap, total_laps)


func _on_timer_changed(time):
	timer_label.text = time


func _on_wrong_way(is_wrong):
	if is_wrong:
		anim.play("wrong_way")
		wrongway_label.visible = true
	else:
		wrongway_label.visible = false


func _on_timeout_trigger(player_name):
	timeout_label.visible = true
	wrongway_label.visible = false


func _on_race_finished(player_name):
	finish_label.visible = true


func _on_velocity_changed(vel):
	km_label.text = str(floor(vel))
	rpm_arrow.rotation_degrees = (vel * 2) - 90
