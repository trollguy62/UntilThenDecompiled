extends Control

const DummyBubble = preload("res://components/SpeechBubble/DummyBubble.gd")

@onready var _base_dummy_bubble = $BaseDummyBubble
@onready var _dummy_bubbles: Array[Node] = \
	get_children().filter(func(n): return n is DummyBubble)


func get_size_of(bbcode_text: String) -> Vector2:
	for i in _dummy_bubbles:
		i.get_size_of(bbcode_text)

	await Utils.wait_frames(2)

	var best_size = _base_dummy_bubble.size

	for i in _dummy_bubbles:
		if i.size.y != _base_dummy_bubble.size.y:
			continue

		if i.size.x < best_size.x:
			best_size = i.size

	return best_size
