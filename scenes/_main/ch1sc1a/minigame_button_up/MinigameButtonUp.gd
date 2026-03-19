extends Node2D

signal finished

const LineConnectStep = preload("res://scenes/_main/ch1sc1a/minigame_button_up/scripts/LineConnectStep.gd")

@onready var cutscene = $Cutscene
@onready var sfx_pop = $Pop
@onready var steps = $Steps

var _playing = false


func _ready():
	visible = false


func start():
	if _playing:
		return
	_playing = true

	to_step("3b_0")
	await wait_connect($"Steps/3b_0")
	sfx_pop.play()

	to_step("3b_1")
	await $"Steps/3b_1/HintBtn".pressed
	sfx_pop.play()

	to_step("3b_2")
	await $"Steps/3b_2/HintBtn".pressed
	sfx_pop.play()

	to_step("3b_3")
	await get_tree().create_timer(1.5).timeout

	steps.visible = false
	cutscene.play("default")
	$Mirror.play()
	await cutscene.animation_finished

	to_step("4b_0")
	await wait_connect($"Steps/4b_0")
	sfx_pop.play()

	to_step("4b_1")
	await $"Steps/4b_1/HintBtn".pressed
	sfx_pop.play()

	to_step("4b_2")
	await $"Steps/4b_2/HintBtn".pressed
	sfx_pop.play()

	to_step("4b_3")
	await $"Steps/4b_3/HintBtn".pressed
	sfx_pop.play()

	to_step("4b_4")

	finished.emit()
	_playing = false


func wait_connect(step: LineConnectStep, correct_idx: int = 0):
	var i = -1
	while i != correct_idx:
		if i != -1:
			step.enabled = false
			await Story.start_short("1.1a.btn_up_fail")
			step.enabled = true
		i = await step.connected


func to_step(name: String):
	steps.visible = true
	for step in steps.get_children():
		step.visible = step.name == name
