extends PanelContainer

signal chosen(idx)

const ANIM_SHOW_HIDE_DUR = 0.25
const V_SPACE_MAX = 28
const V_SPACE_MIN = 28 * 0.25
const H_SPACE_MAX = 96
const H_SPACE_MIN = 96 * 0.5

@onready var tween = Threen.new()
@onready var dummy_bubble = $Control/DummyBubbleManager
@onready var hover_sound = $SoundHover

@onready var spacer_v = $VBox/SpacerV
@onready var spacer_h = $VBox/HBox/SpacerH

@onready var bubble_a = $VBox/HBox/ContainerA/Bubble
@onready var bubble_b = $VBox/HBox/ContainerB/Bubble
@onready var bubble_c = $VBox/ContainerC/Bubble
@onready var bubbles = [bubble_a, bubble_b, bubble_c]

@onready var label_a = $VBox/HBox/ContainerA/Bubble/Label
@onready var label_b = $VBox/HBox/ContainerB/Bubble/Label
@onready var label_c = $VBox/ContainerC/Bubble/Label

@onready var choice_key_a = $VBox/HBox/ContainerA/KeyContainer
@onready var choice_key_b = $VBox/HBox/ContainerB/KeyContainer
@onready var choice_key_c = $VBox/ContainerC/KeyContainer
@onready var choice_keys = [choice_key_a, choice_key_b, choice_key_c]

@onready var timer_display = $VBox/HBox/SpacerH/TimerDisplay

var time_left_fac := 0.0

var _choices: Array = []
var choices: Array:
	set = set_choices,
	get = get_choices


func _ready():
	add_child(tween)

	modulate = Color.TRANSPARENT
	timer_display.material = timer_display.material.duplicate()

	_set_bubbles_clickable(false)

	for i in range(3):
		var choose = _choose.bind(i)
		bubbles[i].pressed.connect(choose)
		choice_keys[i].pressed.connect(choose)


func _process(delta):
	timer_display.material.set_shader_parameter("value", time_left_fac)
	timer_display.visible = time_left_fac > Constants.EPSILON

	if Input.is_action_just_pressed("choice_1"):
		_choose(0)
	elif Input.is_action_just_pressed("choice_2"):
		_choose(2)
	elif Input.is_action_just_pressed("choice_3"):
		_choose(1)


func set_stylebox(stylebox: StyleBox):
	for bubble in [bubble_a, bubble_b, bubble_c]:
		bubble.add_theme_stylebox_override("panel", stylebox)


func set_text_color(text_color: Color):
	for label in [label_a, label_b, label_c]:
		label.add_theme_color_override("default_color", text_color)


func clear_choices():
	await set_choices([])

func set_choices(value: Array):
	assert(value != null)
	_choices = value

	var choice_count = _choices.size()
	var has_choices = choice_count > 1
	var has_choice_c = choice_count > 2

	if has_choices:
		await _set_bubble_text(bubble_a, label_a, _choices[0])
		await _set_bubble_text(bubble_b, label_b, _choices[1])

		if has_choice_c:
			await _set_bubble_text(bubble_c, label_c, _choices[2])

		bubble_c.visible = has_choice_c
		choice_key_c.visible = has_choice_c

		hover_sound.play()

	await _anim_show_choices(has_choices)


func get_choices():
	return _choices


func _set_bubble_text(bubble: PanelContainer, label: RichTextLabel, bbcode_text: String):
	var size = await dummy_bubble.get_size_of(bbcode_text)
	bubble.custom_minimum_size = size
	bubble.size = size
	label.text = bbcode_text


func _anim_show_choices(show: bool):
	var mod = [modulate, modulate]
	mod[1].a = 1 if show else 0

	var sv = [Vector2(0, V_SPACE_MIN), Vector2(0, V_SPACE_MAX)]
	var sh = [Vector2(H_SPACE_MIN, 0), Vector2(H_SPACE_MAX, 0)]

	if not show:
		_set_bubbles_clickable(false)
		sv.reverse()
		sh.reverse()

	tween.interpolate_property(self, "modulate", mod[0], mod[1], ANIM_SHOW_HIDE_DUR)
	tween.interpolate_property(
		spacer_v,
		"custom_minimum_size",
		sv[0],
		sv[1],
		ANIM_SHOW_HIDE_DUR,
		Threen.TRANS_QUAD,
		Threen.EASE_IN_OUT
	)
	tween.interpolate_property(
		spacer_h,
		"custom_minimum_size",
		sh[0],
		sh[1],
		ANIM_SHOW_HIDE_DUR,
		Threen.TRANS_QUAD,
		Threen.EASE_IN_OUT
	)
	tween.start()

	await tween.tween_all_completed

	if show:
		_set_bubbles_clickable(true)


func _set_bubbles_clickable(clickable: bool):
	for bubble in bubbles:
		bubble.clickable = clickable


func _choose(idx: int):
	if idx >= 0 and idx < _choices.size():
		chosen.emit(idx)
