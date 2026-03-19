extends Control

@onready var _tween := Threen.new()

var _content: Array = []  #Array of Control nodes
var _last_index: int = -1
var _next_index: int = -1


func _ready():
	_content = get_children()
	_hide_all_children()
	add_child(_tween)


func show_content(idx: int):
	if idx >= 0 && idx < _content.size():
		var node = _content[idx]
		var slide_from_left = _last_index > idx

		_animate_slide(true, _last_index > idx)
		await _tween.tween_all_completed
		_hide_all_children()

		node.show()
		_animate_slide(false, _last_index < idx)
		await _tween.tween_all_completed
		_last_index = idx


func _hide_all_children():
	for n in get_children():
		if n.has_method("hide"):
			n.hide()


func _remove_all_children():
	for n in get_children():
		if n is Control:
			remove_child(n)


func _animate_slide(out: bool, from_left: bool):
	var colors = [Color.TRANSPARENT, Color.WHITE]
	var anchors = [0.05 * (1 if from_left else -1), 0]
	var easing = Threen.EASE_IN if out else Threen.EASE_OUT
	var duration = 0.2

	if out:
		colors.reverse()
		anchors.reverse()

	_tween.remove_all()
	_tween.interpolate_property(
		self, "modulate", colors[0], colors[1], duration, Threen.TRANS_CUBIC, easing
	)
	_tween.interpolate_property(
		self, "anchor_left", anchors[0], anchors[1], duration, Threen.TRANS_CUBIC, easing
	)
	_tween.interpolate_property(
		self, "anchor_right", anchors[0], anchors[1], duration, Threen.TRANS_CUBIC, easing
	)
	_tween.start()
