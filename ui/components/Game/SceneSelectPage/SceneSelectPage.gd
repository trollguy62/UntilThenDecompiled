extends "res://ui/components/Game/Page.gd"

@onready var back_btn = $BackBtn

@onready var scroll_container = $VBox/SceneSelectContainer/Panel/Scroll
@onready var scene_lists = []
@onready var scene_list = $VBox/SceneSelectContainer/Panel/Scroll/SceneContainer/SceneList
@onready var chapter_list = $VBox/SceneSelectContainer/ChapterList
@onready var button_container = $VBox/ButtonContainer
@onready var button_pt1 = $VBox/ButtonContainer/Button
@onready var button_pt2 = $VBox/ButtonContainer/Button2
@onready var scene_container = $VBox/SceneSelectContainer/Panel/Scroll/SceneContainer



func _ready():
	scene_lists = scene_container.get_children()
	button_container.playthrough_selected.connect(_on_tab_changed)
	
	for sc in scene_lists:
		sc.populate_content(button_pt2.get_path() if Game.ng_plus else back_btn.get_path())
	
	if Game.ng_plus:
		back_btn.focus_neighbor_right = back_btn.get_path_to(button_pt1)

	Game.playthrough_changed.connect(func (pt: int): _on_tab_changed(pt - 1))
	_on_tab_changed(Game.playthrough - 1)


func _enter():
	super._enter()
	button_container.visible = Game.ng_plus
	back_btn.pressed.connect(_page_container.pop)
	chapter_list.chapter_button_pressed.connect(_on_chapter_button_pressed)


func _exit():
	super._exit()
	back_btn.pressed.disconnect(_page_container.pop)
	chapter_list.chapter_button_pressed.disconnect(_on_chapter_button_pressed)


func _process(_delta):
	if is_visible_in_tree():
		_update_active_chapter()


func _update_active_chapter():
	for i in range(scene_list.get_chapter_count() - 1, -1, -1):
		var node = scene_list.get_chapter_title(i)
		var dist = scroll_container.get_scroll_distance_from(node)

		if dist.y <= 32.0:
			chapter_list.active_chapter_idx = i
			break


func _on_chapter_button_pressed(idx: int):
	var node = scene_list.get_chapter_title(idx)
	scroll_container.scroll_to(node)

func _on_tab_changed(tab):
	for sc in scene_lists:
		sc.hide()

	scene_list = scene_lists[tab]
	scene_list.show()
	scene_list._animate_in()

	var pt: int = tab + 1
	chapter_list.playthrough = pt
	Game.playthrough = pt
