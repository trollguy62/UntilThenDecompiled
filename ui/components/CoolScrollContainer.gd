extends ScrollContainer

const DRAGGING_CURSOR: AnimatedTexture = preload("res://assets/ui/cursors/animated_hand_scroll.tres")
const DRAG_DELAY: float = 0.15
const MAX_SCROLL_DIFF_EPSILON: float = 0.2

@export_range(0.0, 1024.0) var scroll_speed = 10.0
@export_range(0.0, 1.0) var scroll_weight = 0.2
@export_range(0.0, 1.0) var auto_scroll_weight = 0.23
@export var enable_improved_follow_focus: bool = false

@onready var drag_delay_timer = Timer.new()

var _velocity = Vector2.ZERO
var _scroll_pos = Vector2(scroll_horizontal, scroll_vertical)
var _old_scroll_pos = Vector2.ZERO
var _target_pos

var _dragging := false:
	set = _set_is_dragging
var is_scrolling := false:
	get: return is_scrolling

func _ready():
	add_child(drag_delay_timer)
	drag_delay_timer.wait_time = DRAG_DELAY
	drag_delay_timer.timeout.connect(_on_drag_delay_timer_timeout)
	get_viewport().gui_focus_changed.connect(_on_gui_focus_changed)

func _process(delta):
	_scroll_pos = _clamp_scroll_pos(_scroll_pos)

	if _old_scroll_pos != _scroll_pos:
		_old_scroll_pos = _scroll_pos
		scroll_horizontal = _scroll_pos.x
		scroll_vertical = _scroll_pos.y
	else:
		# Let `follow_focus` do its job.
		# Or more generally, let `ScrollContainer` do its own job if this class
		# is not doing anything to the scroll position.
		_scroll_pos = Vector2(scroll_horizontal, scroll_vertical)

	var scrolling = abs(_velocity.x) > 0.5 or abs(_velocity.y) > 0.5
	if scrolling != is_scrolling:
		is_scrolling = scrolling

		if scrolling:
			scroll_started.emit()
		else:
			scroll_ended.emit()

	if has_target():
		_scroll_pos = lerp(_scroll_pos, _target_pos, auto_scroll_weight)
		if abs(_scroll_pos.length() - _target_pos.length()) < MAX_SCROLL_DIFF_EPSILON:
			_scroll_pos = _target_pos
			_target_pos = null
			_velocity = Vector2.ZERO
	else:
		_scroll_pos.x = round(_scroll_pos.x + _velocity.x)
		_scroll_pos.y = round(_scroll_pos.y + _velocity.y)
		_velocity = lerp(_velocity, Vector2.ZERO, scroll_weight)

	var rstick_v = Input.get_vector(
		"c_rstick_left", "c_rstick_right", "c_rstick_up", "c_rstick_down"
	)
	if rstick_v.length_squared() > 0.0025:
		_velocity += rstick_v * scroll_speed


func _input(ev):
	if ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT:
		if ev.pressed:
			if Utils.is_mouse_on_control(self):
				drag_delay_timer.start()
		elif drag_delay_timer.is_stopped():
			#currently dragging
			self._dragging = false
		else:
			#not dragging but mouse released before timer has expired
			drag_delay_timer.stop()
			self._dragging = false

	if ev is InputEventMouseMotion:
		if _dragging and not has_target():
			_scroll_pos -= ev.relative
			_release_focus_from_owner()

func _get_optimal_visibility_position(control: Control) -> Vector2:
	var global_rect: Rect2 = get_global_rect()
	var other_rect: Rect2 = control.get_global_rect()
	var v_scroll = get_v_scroll_bar()
	var h_scroll = get_h_scroll_bar()

	var right_margin: float = v_scroll.get_size().x if v_scroll.is_visible() else 0.0
	var bottom_margin: float =  h_scroll.get_size().y if h_scroll.is_visible() else 0.0
#
	var diff = Vector2(max(min(other_rect.position.x, global_rect.position.x), other_rect.position.x + other_rect.size.x - global_rect.size.x + (right_margin if not is_layout_rtl() else 0.0)),
			max(min(other_rect.position.y, global_rect.position.y), other_rect.position.y + other_rect.size.y - global_rect.size.y + bottom_margin));
	var ret = Vector2()
	ret.x = get_h_scroll() + (diff.x - global_rect.position.x);
	ret.y = get_v_scroll() + (diff.y - global_rect.position.y);
	return ret

func _gui_input(ev):
	if ev is InputEventMouseButton:
		match ev.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				_velocity.y -= scroll_speed
			MOUSE_BUTTON_WHEEL_DOWN:
				_velocity.y += scroll_speed
			MOUSE_BUTTON_WHEEL_LEFT:
				_velocity.x -= scroll_speed
			MOUSE_BUTTON_WHEEL_RIGHT:
				_velocity.x += scroll_speed

func _on_gui_focus_changed(control: Control):
	if not enable_improved_follow_focus:
		return

	if self.is_ancestor_of(control):
		_target_pos = _get_optimal_visibility_position(control)

func _release_focus_from_owner():
	var focus_owner := get_viewport().gui_get_focus_owner()
	if focus_owner != null:
		focus_owner.release_focus()


func get_max_scroll_pos() -> Vector2:
	var x = max(0, get_h_scroll_bar().max_value - size.x)
	var y = max(0, get_v_scroll_bar().max_value - size.y)
	return Vector2(x, y)


func _clamp_scroll_pos(scroll_pos: Vector2) -> Vector2:
	var max_scroll = get_max_scroll_pos()
	var clamped = Vector2.ZERO

	clamped.x = clamp(scroll_pos.x, 0, max_scroll.x)
	clamped.y = clamp(scroll_pos.y, 0, max_scroll.y)
	return clamped


func _is_scrolling() -> bool:
	return is_scrolling


func has_target() -> bool:
	return _target_pos is Vector2


func get_scroll_position() -> Vector2:
	return _scroll_pos


func get_scroll_unit_position() -> Vector2:
	var max_scroll_pos = get_max_scroll_pos()
	var unit_pos = Vector2(
		scroll_horizontal / max_scroll_pos.x if max_scroll_pos.x > 0 else 1,
		scroll_vertical / max_scroll_pos.y if max_scroll_pos.y > 0 else 1
	)
	return Vector2(clamp(unit_pos.x, 0, 1), clamp(unit_pos.y, 0, 1))


func get_scroll_distance_from(obj) -> Vector2:
	if obj is Vector2:
		return obj - _scroll_pos
	elif obj is Control:
		return get_scroll_distance_from(_scroll_control_pos_of(obj))
	elif typeof(obj) == TYPE_INT:
		return get_scroll_distance_from(_inferred_child_at(obj))
	else:
		assert(false)
		return Vector2.ZERO


func scroll_to(obj, offset: Vector2 = Vector2.ZERO):
	if obj is Vector2:
		_target_pos = _clamp_scroll_pos(obj + offset)
	elif obj is Control:
		scroll_to(_scroll_control_pos_of(obj), offset)
	elif typeof(obj) == TYPE_INT:
		scroll_to(_inferred_child_at(obj), offset)


func _scroll_control_pos_of(control: Control):
	return control.global_position - global_position + _scroll_pos


func _inferred_child_at(i: int):
	for child in get_children():
		if child is Control:
			if i < 0:
				i += child.get_child_count()
			return child.get_child(i)


func scroll_to_start():
	scroll_to(Vector2.ZERO)


func scroll_to_end():
	scroll_to(get_max_scroll_pos())


func scroll_now_to(scroll_pos: Vector2):
	_scroll_pos = scroll_pos
	_target_pos = scroll_pos


func _on_drag_delay_timer_timeout():
	self._dragging = true


func _set_is_dragging(value):
	if _dragging == value:
		return

	_dragging = value
