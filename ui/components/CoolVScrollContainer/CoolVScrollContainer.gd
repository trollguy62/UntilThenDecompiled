extends Control

const LOCK_END_OFFSET = 100

@export var padding_top := 0
@export var padding_bottom := 0
@export var animate_entry := false
@export var lock_end := false

@onready var scroll = $Mask/VScroll
@onready var tween = Threen.new()
@onready var list = $Mask/VScroll/Content
@onready var header_container = $Mask/VScroll/Content/HeaderContainer
@onready var footer_container = $Mask/VScroll/Content/FooterContainer
@onready var spacer_header = $Mask/VScroll/Content/SpacerHeader
@onready var spacer_footer = $Mask/VScroll/Content/SpacerFooter

@onready var _old_height = size.y

var header: Control:
	set = _set_header,
	get = _get_header
var footer: Control:
	set = _set_footer,
	get = _get_footer

var auto_scroll_weight: float:
	set(value): scroll.auto_scroll_weight = value
	get: return scroll.auto_scroll_weight


func _set_header(value):
	if header_container.get_child_count() == 1:
		header_container.remove_child(header)

	header = value
	if header != null:
		header_container.add_child(header)


func _get_header():
	return header


func _set_footer(value):
	if footer_container.get_child_count() == 1:
		footer_container.remove_child(footer)

	footer = value
	if footer != null:
		footer_container.add_child(footer)


func _get_footer():
	return footer


func _ready():
	scroll.add_child(tween)

	for _i in range(1, get_child_count()):
		var node = get_child(1)
		remove_child(node)
		add_list_item(node)

	resized.connect(_on_resized)

	spacer_header.custom_minimum_size.y = padding_top
	spacer_footer.custom_minimum_size.y = padding_bottom


func _on_resized():
	var height = size.y
	var dh = abs(height - _old_height)

	if dh > 0 and should_autoscroll_to_end():
		await get_tree().process_frame
		scroll_to_end()

	_old_height = height


func add_list_item(node):
	list.add_child(node)
	list.move_child(node, list.get_child_count() - 3)

	if animate_entry:
		_fade_in_new_item(node)

	if should_autoscroll_to_end():
		await get_tree().process_frame
		scroll_to_end()


func _fade_in_new_item(node):
	var to = node.modulate
	node.modulate.a = 0
	tween.interpolate_property(
		node, "modulate", node.modulate, to, 0.1, Threen.TRANS_LINEAR, Threen.EASE_IN
	)
	tween.start()


func remove_list_item(node):
	list.remove_child(node)


func list_item_at(index):
	var i = index + 2
	if i < list.get_child_count():
		return list.get_child(index + 2)


func scroll_to_end():
	scroll.scroll_to_end()


func scroll_end_offset():
	var cur_scroll = scroll.scroll_vertical + size.y
	var max_scroll = scroll.get_v_scroll_bar().max_value
	return max(0, max_scroll - cur_scroll)


func should_autoscroll_to_end():
	return lock_end and scroll_end_offset() <= LOCK_END_OFFSET
