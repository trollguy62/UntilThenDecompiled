extends Control

signal dismissed

@export var duration : float

@onready var animation_player = $AnimationPlayer
@onready var timer = $Timer

var is_dismissed = false

func _ready():
	visibility_changed.connect(_on_visibility_changed)
	timer.timeout.connect(_on_timer_timeout)
	timer.one_shot = true
	timer.start(duration)


func dismiss():
	if is_dismissed:
		return
		
	is_dismissed = true	
	animation_player.play("enter", -1, -1.0, true)
	await animation_player.animation_finished
	dismissed.emit()

func _input(event):
	if event.is_action_pressed("k_interact") or event.is_action_pressed("c_interact"):
		dismiss()


func _on_visibility_changed():
	if visible:
		animation_player.play("enter")


func _on_timer_timeout():
	dismiss()
