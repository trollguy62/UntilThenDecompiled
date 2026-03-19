extends Node2D

const ClickableArea2D = preload("res://components/ClickableArea2D.gd")

signal selected(i)

@export var selection_enabled := false:
	set = _set_selection_enabled,
	get = _get_selection_enabled

@onready var selection_glow = $SelectionGlow
@onready var selection_arrow = $SelectionArrow

@onready var selection_glow_positions = [
	$SelectionGlowPos/Circle, $SelectionGlowPos/Heart, $SelectionGlowPos/Smiley
]
@onready var selection_arrow_positions = [
	$SelectionArrowPos/Circle, $SelectionArrowPos/Heart, $SelectionArrowPos/Smiley
]
@onready var selection_size = selection_glow_positions.size()

@onready var cookie_box_areas = [
	$CookieBoxCircle/Area2D, $CookieBoxHeart/Area2D, $CookieBoxSmiley/Area2D
]

var _selection_idx := -1


func _ready():
	assert(selection_size == selection_arrow_positions.size())
	assert(selection_size == cookie_box_areas.size())

	for i in range(selection_size):
		var area = cookie_box_areas[i] as ClickableArea2D
		area.mouse_entered.connect(_on_cookie_box_hovered.bind(i))
		area.pressed.connect(select.bind(i))


func _process(delta):
	if not is_visible_in_tree():
		return

	var sel_enabled = self.selection_enabled
	selection_glow.visible = sel_enabled
	selection_arrow.visible = sel_enabled

	if not sel_enabled:
		return

	selection_glow.global_position = selection_glow_positions[_selection_idx].global_position
	selection_arrow.global_position = selection_arrow_positions[_selection_idx].global_position


func _input(ev):
	if not is_visible_in_tree():
		return

	if Input.is_action_just_pressed("interact"):
		select(_selection_idx)
	elif self.selection_enabled:
		var di = 0

		if Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("move_left"):
			di = -1
		elif Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("move_right"):
			di = 1

		_selection_idx = fposmod(_selection_idx + di, selection_size)


func select(i: int):
	selected.emit(i)


func set_area_enabled(value):
	for i in range(selection_size):
		cookie_box_areas[i].input_pickable = value


func _set_selection_enabled(value):
	_selection_idx = 1 if value else -1


func _get_selection_enabled():
	return _selection_idx >= 0 and _selection_idx < selection_size


func _on_cookie_box_hovered(i: int):
	if self.selection_enabled:
		_selection_idx = i
