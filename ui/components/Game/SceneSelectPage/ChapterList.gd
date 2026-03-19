extends VBoxContainer

signal chapter_button_pressed(idx)

const ChapterButton = preload("res://ui/components/Game/SceneSelectPage/ChapterButton.tscn")

var active_chapter_idx := -1:
	set = _set_active_chapter_idx

var _is_ready := false
var _chapter_buttons := []

@export_range(1, 3) var playthrough = 1

func _ready():
	Game.playthrough_changed.connect(_on_playthrough_changed)
	_populate_content()


func _on_playthrough_changed(_playthrough):
	playthrough = _playthrough


func _populate_content():
	for child in get_children():
		child.queue_free()
	_chapter_buttons.clear()

	var chapters = Game.scene_directory.chapters

	for i in range(chapters.size()):
		var chapter = chapters[i]

		if chapter.playthrough != playthrough:
			continue


		var chapter_button = ChapterButton.instantiate()
		chapter_button.text = chapter.name
		chapter_button.pressed.connect(
			_on_chapter_button_pressed.bind(_chapter_buttons.size())
		)

		add_child(chapter_button)
		_chapter_buttons.append(chapter_button)

	_is_ready = true

	self.active_chapter_idx = 0

	_animate_in()


func _animate_in():
	var tween = get_tree().create_tween()
	for chapter_button in get_children():
		chapter_button.self_modulate = Color(1.0, 1.0, 1.0, 0.0)
		tween.tween_property(chapter_button, "self_modulate:a", 1.0, 0.12)
		#tween.set_trans(Tween.TRANS_CUBIC)
		tween.set_ease(Tween.EASE_IN)


func _on_chapter_button_pressed(idx: int):
	chapter_button_pressed.emit(idx)


func _set_active_chapter_idx(value: int):
	if not _is_ready or active_chapter_idx == value:
		#re-highlights chapter button just after calling _populate_content
		_chapter_buttons[value].active = true
		return

	if active_chapter_idx >= 0 && active_chapter_idx < _chapter_buttons.size():
		_chapter_buttons[active_chapter_idx].active = false

	_chapter_buttons[value].active = true
	active_chapter_idx = value
