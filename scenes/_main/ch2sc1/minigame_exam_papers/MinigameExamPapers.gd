extends Node2D

const PARENT_HIDDEN_Y = 180

const Folder = preload("res://scenes/_main/ch2sc1/minigame_exam_papers/scripts/Folder.gd")
const Paper = preload("res://scenes/_main/ch2sc1/minigame_exam_papers/scripts/Paper.gd")

signal game_finished

@export var exam_sets : Array[Resource]  = []

@onready var tween : Threen = Threen.new()
@onready var parent = $Parent
@onready var folder = $Parent/Folder
@onready var papers = [$Parent/Paper1, $Parent/Paper2, $Parent/Paper3, $Parent/Paper4]

@onready var sfx_paper_hover = $PaperHover
@onready var sfx_paper_reveal = $PaperReveal
@onready var sfx_paper_pull = $PaperPull
@onready var sfx_slides = [$Slide1, $Slide2, $Slide3, $Slide4]
@onready var pointer = $Pointer

var active_set_idx := -1 : set = _set_active_set_idx ,get = _get_active_set_idx

# We use a callback instead of a signal here because we may need to wait for
# external response to finish
var on_paper_select: Callable  # async? (ExamPaper) -> void



func _ready():
	add_child(tween)
	for paper in papers:
		paper.selected.connect(_on_paper_selected.bind(paper))
		paper.hover_started.connect(_on_paper_hover_started.bind(paper))

func start():
	parent.position.y = PARENT_HIDDEN_Y
	self.active_set_idx = 0


func _on_paper_selected(paper: Paper):
	var idx = papers.find(paper)
	var active_set = _get_active_set()
	var exam_paper: ExamPaper = active_set.exam_papers[idx]
	var is_correct = exam_paper.is_mark

	_set_papers_selection_enabled(false)
	sfx_paper_reveal.play()
	await paper.reveal()

	if on_paper_select.is_valid():
		await on_paper_select.call(exam_paper)


	if is_correct:
		sfx_paper_pull.play()
		await paper.pull_out()
		await _goto_next_set()
	else:
		await paper.unreveal()

	_set_papers_selection_enabled(true)


func _on_paper_hover_started(paper: Paper):
	if sfx_paper_hover.playing and sfx_paper_hover.get_playback_position() < 0.3:
		return
	sfx_paper_hover.play()


func _set_papers_selection_enabled(enabled: bool):
	pointer.visible = enabled
	for paper in papers:
		paper.selection_enabled = enabled


func _goto_next_set():
	var i = self.active_set_idx + 1
	await _set_active_set_idx(i)


func _set_active_set_idx(value):
	if parent == null:
		return

	active_set_idx = value
	_set_papers_selection_enabled(false)
	await _anim_parent_y(180, 0.75)

	if value >= exam_sets.size():
		game_finished.emit()
		return

	for paper in papers:
		paper.restore()

	_change_textures()
	await _anim_parent_y(0, 0.75)
	_set_papers_selection_enabled(true)


func _get_active_set_idx():
	return active_set_idx


func _get_active_set():
	return exam_sets[active_set_idx]


func _change_textures():
	var active_set = _get_active_set()
	folder.texture = active_set.texture

	for i in papers.size():
		var paper = papers[i]
		var texture = active_set.exam_papers[i].texture
		paper.sprite.texture = texture


func _anim_parent_y(y: float, dur: float):
	var p0 = parent.position
	var p1 = Vector2(p0.x, y)

	#tween.stop_all()
	tween.interpolate_property(
		parent, "position", p0, p1, dur, Threen.TRANS_CUBIC, Threen.EASE_IN_OUT
	)
	tween.start()

	_play_slide_sfx()

	await tween.tween_completed



func _play_slide_sfx():
	var sfx_idx = randi() % 4
	sfx_slides[sfx_idx].play()
