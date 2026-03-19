extends Control

signal page_stack_changed

const Page = preload("res://ui/components/Game/Page.gd")

@onready var tween := Threen.new()

@export var initial_page: PackedScene
@export var transition_duration := 0.2
@export var transition_scale := 0.8

var _page_stack: Array = []
var _current_page_parent: Node = null

var current_page: Page:
	get: return _page_stack.back()
var page_count: int:
	get: return _page_stack.size()


func _ready():
	add_child(tween)

	if initial_page:
		push(initial_page.instantiate())


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		for page in _page_stack:
			if is_instance_valid(page):
				page.queue_free()


func push(page: Page):
	if is_busy():
		return

	if not _page_stack.is_empty():
		await _exit_page()

	_page_stack.push_back(page)
	await _enter_page(page)

	page_stack_changed.emit()


func pop():
	if is_busy():
		return

	if not _page_stack.is_empty():
		await _exit_page()
		_page_stack.pop_back()

	if not _page_stack.is_empty():
		var top = _page_stack.back()
		await _enter_page(top)

	page_stack_changed.emit()


func reenter():
	if is_busy():
		return

	if self.page_count > 0:
		var page = self.current_page
		page.call_deferred("_enter")
		await _animate_page(page, true)


func is_busy() -> bool:
	return tween.is_active()


func _exit_page():
	var top = _page_stack.back()
	top._exit()
	await _animate_page(top, false)

	if _current_page_parent:
		top.reparent(_current_page_parent)
	else:
		remove_child(top)


func _enter_page(page: Page):
	page._page_container = self

	_current_page_parent = page.get_parent()
	if _current_page_parent != null:
		page.reparent(self)
	else:
		add_child(page)

	Utils.refresh_locale()
	page.call_deferred("_enter")
	await _animate_page(page, true)


func _animate_page(page: Page, show: bool):
	var scale = [Vector2.ONE * transition_scale, Vector2.ONE]
	var color = [Color.TRANSPARENT, Color.WHITE]
	var easing = Threen.EASE_OUT if show else Threen.EASE_IN

	if not show:
		scale.reverse()
		color.reverse()

	page.modulate = color[0]
	page.pivot_offset = page.size / 2.0

	tween.interpolate_property(
		page, "scale", scale[0], scale[1], transition_duration, Threen.TRANS_CUBIC, easing
	)
	tween.interpolate_property(page, "modulate", color[0], color[1], transition_duration)
	tween.start()

	await tween.tween_completed
