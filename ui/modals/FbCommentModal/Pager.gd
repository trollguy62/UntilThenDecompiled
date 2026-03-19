extends Panel

signal tween_completed

@onready var tween = Threen.new()

@export var page_index = 0:
	set(value):
		if page_index != value:
			page_index = value
			_update()
	get:
		return page_index

var pages: Array:
	get:
		var pages = get_children()
		pages.erase(tween)
		return pages

var _is_ready = false


func _ready():
	add_child(tween)
	_is_ready = true
	resized.connect(_on_resized)


func _on_resized():
	_update()


func _update():
	if not _is_ready:
		return

	var pages = self.pages
	var width = size.x
	var offset = width * page_index

	for i in range(pages.size()):
		var child = pages[i]
		child.custom_minimum_size.x = width

		var p0 = child.position
		var p1 = Vector2(i * width - offset, p0.y)
		tween.interpolate_property(
			child, "position", p0, p1, 0.3, Threen.TRANS_CUBIC, Threen.EASE_IN_OUT
		)

	tween.start()
	tween.tween_all_completed.connect(func(): tween_completed.emit(), CONNECT_ONE_SHOT)


func add_page(page: Control):
	add_child(page)
	_update()
