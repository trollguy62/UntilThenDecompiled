extends PanelContainer

signal value_changed(value: float)
signal pressed()

@export var value := 1.0:
	set(v):
		if value == v:
			return

		value = v
		value_changed.emit(value)

		if is_node_ready():
			_update()

@export var step := 0.1
@export var step_echo_mult := 10.0
@export var min_value := 0.0
@export var max_value := 10.0

@export var text := "%f":
	set(v):
		text = v
		if is_node_ready():
			_update()

@onready var arrow_left = $HBox/ArrowLeft
@onready var arrow_right = $HBox/ArrowRight
@onready var label = $HBox/Label
@onready var stylebox = get_theme_stylebox("panel").duplicate()


func _ready():
	assert(step > 0)
	_update()
	
	stylebox.bg_color.a = 0
	set("theme_override_styles/panel", stylebox)

	focus_entered.connect(func(): stylebox.bg_color.a = 0.1)
	focus_exited.connect(func(): stylebox.bg_color.a = 0)
	
	arrow_left.pressed.connect(_step_value.bind(false))
	arrow_right.pressed.connect(_step_value.bind(true))


func _gui_input(ev: InputEvent):
	if ev.is_action_pressed("ui_left", true):
		_step_value(false, ev.is_echo())
		accept_event()
	elif ev.is_action_pressed("ui_right", true):
		_step_value(true, ev.is_echo())
		accept_event()
	elif ev.is_action_pressed("ui_accept"):
		pressed.emit()
	elif ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT \
			and ev.pressed and not ev.is_echo():
		pressed.emit()


func _step_value(increment: bool, is_echo: bool = false):
	grab_focus()
	var mult = step_echo_mult if is_echo else 1
	
	if increment:
		value = min(value + step * mult, max_value)
	else:
		value = max(value - step * mult, min_value)


func _update():
	label.text = text % value
	arrow_left.self_modulate.a = 1 if value > min_value else 0.4
	arrow_right.self_modulate.a = 1 if value < max_value else 0.4
