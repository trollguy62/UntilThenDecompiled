extends Node

const ExamPaper = preload("res://scenes/_main/ch2sc1/minigame_exam_papers/scripts/ExamPaper.gd")

@onready var minigame = get_parent()
@onready var focus = $Focus
@onready var scene_manager = Service.of("SceneManager") as SceneManager


func _ready():
	minigame.visible = false
	scene_manager.shot_changed.connect(_on_shot_changed)
	minigame.game_finished.connect(_on_game_finished)
	minigame.on_paper_select = _minigame_exam_papers_on_paper_select


func _on_shot_changed(shot: String):
	var is_visible = shot == "MinigameExamPapers"
	minigame.visible = is_visible

	if is_visible:
		focus.push()
		minigame.start()
	else:
		focus.pop()


func _on_game_finished():
	Story.emit("minigame_exam_papers_finished")


func _minigame_exam_papers_on_paper_select(exam_paper: ExamPaper):
	var suffix = "avg"

	if exam_paper.is_mark:
		if exam_paper.subject == "Art":
			suffix = "correct_art"
		else:
			suffix = "correct"
	elif exam_paper.score >= 42:
		suffix = "high"
	elif exam_paper.score <= 33:
		suffix = "low"

	var short_id = "2.1.ExamPapers_" + suffix
	await Story.start_short(short_id)
