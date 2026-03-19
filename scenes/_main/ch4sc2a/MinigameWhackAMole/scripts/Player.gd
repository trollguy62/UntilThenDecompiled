extends Node

signal mole_hit(score)

@onready var score_text = $Score
@onready var mole_manager = $MoleManager
@onready var hammer = $Hammer

var current_score = 0

func _ready():
	mole_manager.mole_hit.connect(_on_mole_hit)

func start():
	mole_manager.start()
	reset()

func stop():
	mole_manager.stop()

func reset():
	current_score = 0
	score_text.text = "%03d" %  current_score

func _on_mole_hit(score):
	mole_hit.emit(score)
	current_score += score
	if current_score < 0:
		current_score = 0

	score_text.text = "%03d" %  current_score
