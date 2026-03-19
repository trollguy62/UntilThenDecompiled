extends Node2D

signal wrong_connection
signal finished

const LineConnectStep = preload("LineConnectStep.gd")

@onready var focus = $Focus
@onready var steps = $Steps


func start():
	focus.push()
	await to_step("A_0")
	await to_step("A_1")
	await to_step("A_2")
	focus.pop()
	finished.emit()


func to_step(name: String):
	await get_tree().process_frame
	var step

	for child in steps.get_children():
		child.visible = child.name == name
		if child.visible:
			step = child

	assert(step != null)

	if step is LineConnectStep:
		var correct = false

		while not correct:
			correct = await step.connected

			if not correct:
				wrong_connection.emit()
