extends Node

#warning-ignore:unused_signal
signal chosen(idx)
#warning-ignore:unused_signal
signal choices_changed
#warning-ignore:unused_signal
signal choice_revealed
#warning-ignore:unused_signal
signal choices_timed_out(fallback_idx)

const AccurateDelaySource = preload("res://components/AccurateDelaySource.gd")

const DialogueText = preload("res://data/DialogueText.gd")

const State = preload("res://data/State.gd")
const SubstoryContext = preload("res://data/story/SubstoryContext.gd")

const tail_complete = preload("res://components/SpeechBubble/assets/tail_complete.png")
const tail_corner_cut = preload("res://components/SpeechBubble/assets/tail_corner_cut.png")

enum Orientation { TOP, TOP_LEFT, LEFT, BOTTOM_LEFT, BOTTOM, BOTTOM_RIGHT, RIGHT, TOP_RIGHT }

const ORIENTATION_ROT_DEGS = {
	Orientation.TOP: 0,
	Orientation.TOP_LEFT: -45,
	Orientation.LEFT: -90,
	Orientation.BOTTOM_LEFT: -135,
	Orientation.BOTTOM: 180,
	Orientation.BOTTOM_RIGHT: 135,
	Orientation.RIGHT: 90,
	Orientation.TOP_RIGHT: 45
}

const TAIL_LENGTH = 32
const TAIL_WIDTH = 16
const DIAG = 0.70710678  # sqrt(2) / 2

const PAGE_IND_V_MARGIN = 12

const BG_COLOR_OPACITY = 220.0 / 255.0
const CORNER_RADIUS = 16
const AUTO_HIDE_DELAY = 0.1

const ANIM_SHOW_HIDE_DUR = 0.25
const ANIM_BUBBLE_RESIZE_DUR = 0.3
const ANIM_TEXT_FADE_DUR = 0.1
const ANIM_UPDATE_THEME_DUR = 0.2
const ANIM_SLIDE_DUR = 0.1

const DEF_COLOR = Color("#000")
const DEF_TEXT_COLOR = Color("#FFF")
const MAX_SORT_DISTANCE = 30.0
const MIN_SORT_DISTANCE = -30.0

const ADAPTIVE_PX_MARGIN = 40.0
const ADAPTIVE_DISJOINT_MARGIN = 2.0  #ceil(sqrt(CORNER_RADIUS) * 1.41421356237)

const PROCESS_PRIORITY = -20

@export var alias: String = ""
# Theme properties don't immediately reflect until bubble text appears or changes
@export var color: Color = DEF_COLOR
@export var text_color: Color = DEF_TEXT_COLOR

@onready var control = $CanvasLayer/Control
@onready var bubble = $CanvasLayer/Control/Bubble
@onready var label = $CanvasLayer/Control/Bubble/Label
@onready var hint_next = $CanvasLayer/Control/HintNext
@onready var tail = $CanvasLayer/Control/Tail
@onready var dummy_bubble = $CanvasLayer/Control/DummyBubbleManager
@onready var choice_group = $CanvasLayer/ChoiceGroup
@onready var canvas_layer = $CanvasLayer

@onready var tween = Threen.new()
@onready var timer = $Timer
@onready var limit_timer = $LimitTimer
@onready var hover_sound = $SoundHover
@onready var text_sound = $SoundText

var _state: SbState

var _control_pos = Vector2.ZERO
var _override_orientation := -1
var _pivot: Node
var _time_limit_fallback_idx := -1

var _dlg_text: DialogueText
var choices: Array:
	set = _set_choices,
	get = _get_choices
var context: SubstoryContext:
	set = _set_context,
	get = _get_context

var _target_size = Vector2():
	set(v):
		_anim_delta = 0
		_target_size = v
var _last_size = Vector2()
var _anim_delta = 0

func _ready():
	process_priority = PROCESS_PRIORITY
	self.context = null
	add_child(tween)

	_init_bubble()
	_update_theme()

	get_viewport().size_changed.connect(_on_window_resized)
	limit_timer.timeout.connect(_on_limit_timer_timeout)

	_update_control()

	self.color = color
	_set_state(HiddenState.new(self))


func _init_bubble():
	control.modulate = Color.TRANSPARENT

	var stylebox = bubble.get_theme_stylebox("panel").duplicate()
	bubble.add_theme_stylebox_override("panel", stylebox)
	choice_group.set_stylebox(stylebox)


func _set_choices(value: Array):
	# Convert String elements to DialogueText if any
	for i in range(value.size()):
		var e = value[i]
		if e is String:
			value[i] = DialogueText.new(e)

		assert(value[i] is DialogueText)

	choices = value

	await get_tree().process_frame
	choices_changed.emit()


func _get_choices():
	return choices


func _set_context(value):
	if not value is SubstoryContext:
		value = Story.context

	if context != value:
		context = value
		_pivot = null  # Reset pivot on context change


func _get_context():
	return context


func _set_state(value):
	if _state != null:
		_state.exit()
	_state = value
	_state.enter()


func _unhandled_input(ev):
	var next_state = _state._input(ev)
	if next_state != null:
		_set_state(next_state)


func _process(delta):
	if has_time_limit():
		var x = limit_timer.time_left / limit_timer.wait_time
		choice_group.time_left_fac = x
	else:
		choice_group.time_left_fac = 0.0

	var next_state = _state._process(delta)
	if next_state != null:
		_set_state(next_state)

	if _is_bubble_visible():
		hover_sound.volume_db = linear_to_db(bubble.get_percent_visible_area())
		text_sound.volume_db = linear_to_db(bubble.get_percent_visible_area())


func _is_valid_pivot(node: Node):
	return (
		node != null
		and node.get_class() == "SpeechBubblePivot"
		and node.is_visible_in_tree()
		and node.alias == alias
	)


func _update_control():
	if _pivot == null or not _is_valid_pivot(_pivot):
		_pivot = context.get_speech_bubble_pivot(alias)

	_update_control_position()
	_update_control_orientation()
	_update_adaptive_position()
	_update_hint_next_position()


func _update_control_position():
	if _pivot != null:
		var viewport = get_viewport()
		var camera = viewport.get_camera_3d()
		var is_behind = false

		if _pivot is Marker3D and camera != null:
			var world_pos = _pivot.global_transform.origin
			_control_pos = camera.unproject_position(world_pos)
			is_behind = (
				camera.global_transform.basis.z.dot(world_pos - camera.global_transform.origin)
				>= 0
			)

			var direction_vector = world_pos - camera.global_transform.origin
			var projection_amount = (-camera.global_transform.basis.z).dot(direction_vector)
			projection_amount = clamp(projection_amount, MIN_SORT_DISTANCE, MAX_SORT_DISTANCE)
			canvas_layer.layer = int(
				remap(world_pos.z, projection_amount, projection_amount, 1, 128)
			)
		elif _pivot is Marker2D:
			_control_pos = _pivot.global_position

		_override_orientation = -1

		if _pivot.force_show:
			var viewport_rect = viewport.get_visible_rect()
			var sb_rect = viewport_rect.grow(-_pivot.force_show_margin)

			if not sb_rect.has_point(_control_pos):
				# TODO: Rudimentary handling of is_position_behind. Improve.
				if is_behind:
					var viewport_center = viewport_rect.size / 2
					_control_pos = 2 * viewport_center - _control_pos

				var normalized_pos = (_control_pos - sb_rect.size / 2.0) * Vector2(1, -1)

				var theta = _regular_angle(normalized_pos, sb_rect)
				var i = posmod(int(floor((theta - PI / 8.0) / (PI / 4.0))) - 5, 8)

				_control_pos = _point_on_rect(_control_pos, sb_rect)
				_override_orientation = i

		control.position = _control_pos
	else:
		control.position = Vector2(-999, -999)


func _point_on_rect(p: Vector2, r: Rect2) -> Vector2:
	assert(not r.has_point(p))

	var minr = r.position
	var maxr = r.end

	var mid = r.position + r.size / 2.0
	var m = (mid.y - p.y) / (mid.x - p.x)

	if p.x <= mid.x:
		var min_xy = m * (minr.x - p.x) + p.y
		if minr.y <= min_xy && min_xy <= maxr.y:
			return Vector2(minr.x, min_xy)

	if p.x >= mid.x:
		var max_xy = m * (maxr.x - p.x) + p.y
		if minr.y <= max_xy && max_xy <= maxr.y:
			return Vector2(maxr.x, max_xy)

	if p.y <= mid.y:
		var min_yx = (minr.y - p.y) / m + p.x
		if minr.x <= min_yx && min_yx <= maxr.x:
			return Vector2(min_yx, minr.y)

	if p.y >= mid.y:
		var max_yx = (maxr.y - p.y) / m + p.x
		if minr.x <= max_yx && max_yx <= maxr.x:
			return Vector2(max_yx, maxr.y)

	return p


func _regular_angle(p: Vector2, r: Rect2) -> float:
	var transformation = Vector2.ONE

	if r.size.x > r.size.y:
		transformation.x = r.size.y / r.size.x
	else:
		transformation.y = r.size.x / r.size.y

	return (p * transformation).angle()


func _update_control_orientation():
	if _pivot == null:
		return
	var pos = Vector2.ZERO
	var orientation = _pivot.orientation

	if _override_orientation >= 0:
		orientation = _override_orientation

	if _anim_delta < ANIM_BUBBLE_RESIZE_DUR:
		bubble.size = Tween.interpolate_value(_last_size, _target_size - _last_size, _anim_delta,
				ANIM_BUBBLE_RESIZE_DUR, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		_anim_delta += get_process_delta_time()
	else:
		bubble.size = _target_size

	var hl = -TAIL_WIDTH / 2.0 - CORNER_RADIUS
	var hr = -bubble.size.x - hl

	match orientation:
		Orientation.LEFT:
			pos.x = -bubble.size.x - TAIL_LENGTH
		Orientation.TOP_LEFT, Orientation.BOTTOM_LEFT:
			pos.x = hr - TAIL_LENGTH * DIAG - CORNER_RADIUS
		Orientation.TOP, Orientation.BOTTOM:
			pos.x = (hl + hr) / 2
		Orientation.TOP_RIGHT, Orientation.BOTTOM_RIGHT:
			pos.x = hl + TAIL_LENGTH * DIAG + CORNER_RADIUS
		Orientation.RIGHT:
			pos.x = TAIL_LENGTH

	match orientation:
		Orientation.TOP:
			pos.y = -bubble.size.y - TAIL_LENGTH
		Orientation.TOP_LEFT, Orientation.TOP_RIGHT:
			pos.y = -bubble.size.y - TAIL_LENGTH * DIAG + TAIL_WIDTH / 2.0
		Orientation.LEFT, Orientation.RIGHT:
			pos.y = -bubble.size.y / 2
		Orientation.BOTTOM_LEFT, Orientation.BOTTOM_RIGHT:
			pos.y = TAIL_LENGTH * DIAG - TAIL_WIDTH / 2.0
		Orientation.BOTTOM:
			pos.y = TAIL_LENGTH

	var tail_rot = ORIENTATION_ROT_DEGS[orientation]

	var tail_texture = tail_complete if posmod(tail_rot, 90) == 0 else tail_corner_cut

	tail.rotation_degrees = tail_rot
	tail.texture = tail_texture
	bubble.position = pos


func _update_adaptive_position():
	if not (_pivot and _pivot.adaptive):
		return

	var viewport_rect: Rect2 = get_viewport().get_visible_rect()
	var sb_rect = viewport_rect.grow(-_pivot.force_show_margin + ADAPTIVE_DISJOINT_MARGIN)
	var bubble_rect: Rect2 = bubble.get_rect()
	var tail_rect: Rect2 = sb_rect.grow(-TAIL_LENGTH)
	bubble_rect.position += bubble.global_position

	if not sb_rect.encloses(bubble_rect) and tail_rect.has_point(tail.global_position):
		var TOTAL_MARGIN = Vector2(ADAPTIVE_PX_MARGIN, ADAPTIVE_PX_MARGIN)
		var diff: Vector2 = (
			bubble.global_position
			+ bubble.size
			- (viewport_rect.size - TOTAL_MARGIN)
		)
		var max_allowance = bubble_rect.size - TOTAL_MARGIN

		var is_diff_less_than_size_x = abs(diff.x) < bubble_rect.size.x
		var is_diff_less_than_size_y = abs(diff.y) < bubble_rect.size.y
		var left_diff = bubble.global_position.x - sb_rect.position.x
		var top_diff = bubble.global_position.y - sb_rect.position.y

		var x_flag = false #this becomes true if we have adjusted the x pos
		#skip x adj if orientation is left or right
		if not (_pivot.orientation == Orientation.LEFT or _pivot.orientation == Orientation.RIGHT):
			if bubble_rect.end.x > sb_rect.end.x && is_diff_less_than_size_x:
				bubble.position.x -= diff.x
				x_flag = true

			if (
				bubble.global_position.x < sb_rect.position.x
				and abs(left_diff) < max_allowance.x
			):
				bubble.global_position.x = sb_rect.position.x
				x_flag = true
			#return here because we only really need to move on one axis at most
			if x_flag:
				return

		#skip y adj if orientation is top or bottom
		if not (_pivot.orientation == Orientation.TOP or _pivot.orientation == Orientation.BOTTOM) and not x_flag:
			if (
				bubble.global_position.y < sb_rect.position.y
				and abs(top_diff) < max_allowance.y
			):
				bubble.global_position.y = sb_rect.position.y

			if bubble_rect.end.y > sb_rect.end.y && is_diff_less_than_size_y:
				bubble.position.y -= diff.y

			#return here because we only really need to move on one axis at most
			return


func _update_hint_next_position():
	hint_next.position = (
		bubble.position
		+ bubble.size
		- Vector2(hint_next.size.x + CORNER_RADIUS, hint_next.size.y / 2)
	)


func _show_hint_next():
	await hint_next.show_hint()


func _hide_hint_next():
	await hint_next.hide_hint()


func _on_window_resized():
	_set_dlg_text(_dlg_text)  # Adjusts text to new resolution


func _set_dlg_text(value: DialogueText):
	var old_value = _dlg_text
	_dlg_text = value

	if label == null:
		return

	var old_empty = old_value == null
	var new_empty = value == null
	var final_text = "" if new_empty else value.final_text

	tween.remove_all()

	if new_empty and not old_empty:
		_set_active(false)
		await Utils.wait(0)
		return

	elif old_empty and not new_empty:
		var size = await dummy_bubble.get_size_of(final_text)
		label.text = ""
		#bubble.custom_minimum_size = size
		bubble.size = size
		_last_size = size
		_target_size = size
		_update_theme()
		_set_active(true)
		#_target_size = size

	elif not old_empty and not new_empty:
		var from_size = bubble.size
		var to_size = await dummy_bubble.get_size_of(final_text)

		await _fade_out_text()
		label.text = ""

		_update_theme()
		await _set_active(true)
		_last_size = from_size
		_target_size = to_size
		await Utils.wait(ANIM_BUBBLE_RESIZE_DUR)
		await get_tree().process_frame

	label.text = final_text
	label.modulate = Color.WHITE


func push_time_limit(duration: float, fallback_idx: int):
	_time_limit_fallback_idx = fallback_idx
	limit_timer.start(duration)


func has_time_limit() -> bool:
	return _time_limit_fallback_idx >= 0


func _on_limit_timer_timeout():
	choices_timed_out.emit(_time_limit_fallback_idx)
	_time_limit_fallback_idx = -1


func _update_theme():
	var stylebox = bubble.get_theme_stylebox("panel")
	var bg_color = color
	bg_color.a = BG_COLOR_OPACITY

	stylebox.bg_color = bg_color
	tail.modulate = bg_color

	label.add_theme_color_override("default_color", text_color)
	choice_group.set_text_color(text_color)


func _is_bubble_visible() -> bool:
	return control.modulate.a > 0


func _set_active(active: bool):
	var scale = [Vector2.ONE, Vector2.ZERO]
	var modulate = [Color.WHITE, Color.TRANSPARENT]
	if active:
		scale.reverse()
		modulate.reverse()

	# Abort if already visually (in)active
	if Utils.equals(control.scale, scale[1]) and Utils.equals(control.modulate, modulate[1]):
		return

	if active:
		hover_sound.play()
		hint_next.modulate = Color.TRANSPARENT

	tween.interpolate_property(
		control,
		"scale",
		scale[0],
		scale[1],
		ANIM_SHOW_HIDE_DUR,
		Threen.TRANS_CUBIC,
		Threen.EASE_IN_OUT
	)
	tween.interpolate_property(
		control,
		"modulate",
		modulate[0],
		modulate[1],
		ANIM_SHOW_HIDE_DUR,
		Threen.TRANS_LINEAR,
		Threen.EASE_IN
	)
	tween.start()
	await tween.tween_all_completed

func _fade_out_text():
	var c = [Color.WHITE, Color.TRANSPARENT]
	tween.interpolate_property(
		label, "modulate", c[0], c[1], ANIM_TEXT_FADE_DUR, Threen.TRANS_LINEAR, Threen.EASE_IN
	)
	tween.start()
	await tween.tween_all_completed


class SbState:
	extends State

	const Command = preload("res://data/Command.gd")
	const DialogueText = preload("res://data/DialogueText.gd")

	var sb

	func _init(sb):
		self.sb = sb

	func _is_advance_pressed() -> bool:
		var debug_next = Utils.is_debug() and Input.is_key_pressed(KEY_P) \
				and not Game.record_replay_is_active()

		return (
			Input.is_action_just_pressed("ui_accept")
			or Utils.is_skip_text_pressed()
			or debug_next
			or sb.bubble.consume_click()
			or sb.hint_next.consume_click()
		)


class HiddenState:
	extends SbState
	var next = false

	func _init(sb):
		super(sb)
		sb.timer.timeout.connect(_hide_bubble)

	func _hide_bubble():
		sb._set_dlg_text(null)

	func enter():
		await sb.choices_changed
		if not sb.choices.is_empty():
			next = true

	func exit():
		sb.timer.timeout.disconnect(_hide_bubble)

	func _process(delta):
		if sb._is_bubble_visible():
			sb._update_control()

		if not next:
			return

		var choice_count = sb.choices.size()

		if choice_count == 1:
			return RevealTextState.new(sb, sb.choices[0])
		elif choice_count > 1:
			if sb._dlg_text != null:
				_hide_bubble()
			return RevealChoicesState.new(sb, sb.choices)


class RevealTextState:
	extends SbState
	var dlg_text: DialogueText
	var skip_reveal = false
	var next = false

	func _init(sb, dlg_text: DialogueText):
		super(sb)
		assert(dlg_text != null)
		self.dlg_text = dlg_text

	func enter():
		await sb._set_dlg_text(dlg_text)
		await _reveal_text()

		if not dlg_text.is_timed():
			sb._show_hint_next()
		if is_instance_valid(sb):
			sb.choice_revealed.emit()
		next = true

	func _process(_delta):
		sb._update_control()

		if _is_advance_pressed() and not dlg_text.is_timed():
			skip_reveal = true

		if next:
			return PendingAdvanceState.new(sb, dlg_text)

	func _reveal_text():
		var delay_src = AccurateDelaySource.new()
		skip_reveal = false

		for step in dlg_text.steps:
			if next or not is_instance_valid(sb):
				return

			if step is int:
				sb.label.visible_characters = step
				_try_play_text_sound()

			elif step is DialogueText.DelayInst:
				if not skip_reveal:
					await delay_src.delay(step.duration)

			elif step is Command:
				var run = func(): await sb.context.run_command(step)

				if not skip_reveal:
					await run.call()
				else:
					run.call()

	func _try_play_text_sound():
		if not sb.text_sound.playing:
			sb.text_sound.play()


class RevealChoicesState:
	extends SbState
	var choices: Array
	var next = false

	func _init(sb, choices: Array):
		super(sb)
		assert(choices.size() > 1)
		self.choices = choices

	func enter():
		var text_choices = []
		for choice in choices:
			text_choices.append(choice.final_text)

		await sb.choice_group.set_choices(text_choices)
		next = true

	func _process(delta):
		if next:
			return PendingChoiceState.new(sb)


class PendingAdvanceState:
	extends SbState
	var dlg_text: DialogueText

	func _init(sb, dlg_text: DialogueText):
		super(sb)
		assert(dlg_text != null)
		self.dlg_text = dlg_text

	func _process(delta):
		sb._update_control()

		if _is_advance_pressed() or dlg_text.is_timed() or sb.choices.is_empty():
			if not dlg_text.is_timed():
				sb._hide_hint_next()

			sb.timer.start(AUTO_HIDE_DELAY)
			sb.chosen.emit(0)
			return HiddenState.new(sb)


class PendingChoiceState:
	extends SbState
	var chosen_idx: int = -1

	func _init(sb):
		super(sb)

	func enter():
		sb.choice_group.chosen.connect(_choose)
		sb.choices_timed_out.connect(_choose)

	func exit():
		sb.choice_group.chosen.disconnect(_choose)

	func _process(_delta):
		if sb.choices.is_empty():
			chosen_idx = 0

		if chosen_idx >= 0:
			sb.timer.start(AUTO_HIDE_DELAY)
			sb.chosen.emit(chosen_idx)

			sb.choice_group.clear_choices()
			return HiddenState.new(sb)

	func _choose(idx: int):
		if not sb.has_time_limit():
			await sb.choice_group.clear_choices()

		chosen_idx = idx
