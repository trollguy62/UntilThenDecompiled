extends VBoxContainer

const VERTICAL_INSET = 24.0
const CHAPTER_INSET = 12.0

const chapter_title_font = preload("res://fonts/NunitoSans-Regular-28.tres")
const SceneInfo = preload("res://data/SceneInfo.gd")
const SceneView = preload("res://ui/components/Game/SceneView/SceneView.tscn")

@export_range(1, 3) var playthrough = 1

var _last_scene_view_click_area: Button = null
var _chapter_titles := []
var _style_box_empty := StyleBoxEmpty.new()


func populate_content(top_node_path: NodePath):
	for child in get_children():
		child.queue_free()
	_chapter_titles.clear()

	var chapters = Game.scene_directory.chapters

	for i in range(chapters.size()):
		var chapter = chapters[i]

		if chapter.playthrough != playthrough:
			continue

		_add_inset(CHAPTER_INSET)
		_add_chapter_title(chapter.name)

		for key in chapter.scenes:
			var scene_info: SceneInfo = Game.scene_directory.get_scene_info(key)

			if scene_info.is_hidden():
				continue

			_add_scene_view(key, scene_info, top_node_path)

	_add_inset(VERTICAL_INSET)


func _add_chapter_title(text: String):
	var label = Label.new()
	label.add_theme_font_override("font", chapter_title_font)
	label.add_theme_font_size_override("font_size", 28)
	label.text = text

	add_child(label)
	_chapter_titles.append(label)


func _add_scene_view(key: String, scene_info: SceneInfo, top_node_path: NodePath):
	var scene_view = SceneView.instantiate()
	var scene_name = scene_info.name
	scene_view.metadata = {"key": key, "name": scene_name}
	
	add_child(scene_view)
	
	if _last_scene_view_click_area:
		scene_view.click_area.focus_neighbor_top = scene_view.click_area.get_path_to(_last_scene_view_click_area)
	else:
		var top_node = get_node(top_node_path)
		scene_view.click_area.focus_neighbor_top = scene_view.click_area.get_path_to(top_node)
	
	_last_scene_view_click_area = scene_view.click_area

func _add_inset(height):
	var inset = PanelContainer.new()
	inset.add_theme_stylebox_override("panel", _style_box_empty)
	inset.custom_minimum_size = Vector2(0, height)
	add_child(inset)


func _animate_in():
	modulate.a = 0.0
	modulate = Color(1.0, 1.0, 1.0, 0.0)

	if is_inside_tree():
		var tween = get_tree().create_tween()
		tween.tween_property(self, "modulate", Color.WHITE, 0.3)
		tween.set_ease(Tween.EASE_OUT)
	else:
		self.modulate = Color.WHITE

func _process(delta):
	for c in get_children():
		c.modulate = modulate

func get_chapter_title(idx: int) -> Label:
	return _chapter_titles[idx]


func get_chapter_count() -> int:
	return _chapter_titles.size()
