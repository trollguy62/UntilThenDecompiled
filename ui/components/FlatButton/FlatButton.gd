extends PanelContainer

signal pressed

@export var bg_color = Color.WHITE:
	set(value):
		bg_color = value
		if tween:  # Retain alpha
			var color = bg_color
			color.a = _stylebox.bg_color.a
			_stylebox.bg_color = color
	get:
		return bg_color

@export_range(0.0, 1.0) var idle_alpha = 0.0:
	set(value):
		idle_alpha = value
		if tween and not _mouse_entered and not disabled:
			_set_bg_alpha(idle_alpha)
	get:
		return idle_alpha

@export_range(0.0, 1.0) var hover_alpha = 0.2
@export_range(0.0, 1.0) var press_alpha = 0.3
@export var disabled = false

@export var corner_radius = 8
@export var content_margin_right = 8
@export var content_margin_top = 8
@export var content_margin_left = 8
@export var content_margin_bottom = 8

@onready var content = $Content
@onready var tween = Threen.new()
@onready var child = get_child(2)
@onready var clickable = $Clickable

var _stylebox: StyleBoxFlat
var _mouse_entered := false


func _ready():
	focus_entered.connect(_on_hovered)
	focus_exited.connect(_on_unhovered)
	clickable.hovered.connect(_on_hovered)
	clickable.unhovered.connect(_on_unhovered)
	clickable.mouse_down.connect(_on_mouse_down)
	clickable.mouse_up.connect(_on_mouse_up)
	clickable.pressed.connect(_on_pressed)

	remove_child(child)
	content.add_child(child)
	add_child(tween)

	_stylebox = get_theme_stylebox("panel").duplicate()
	_stylebox.bg_color = bg_color
	_stylebox.bg_color.a = idle_alpha
	add_theme_stylebox_override("panel", _stylebox)

	set_margins(
		content_margin_right, content_margin_top, content_margin_left, content_margin_bottom
	)
	set_corner_radius(corner_radius)

	self.bg_color = bg_color
	self.idle_alpha = idle_alpha


func _on_mouse_down():
	_set_bg_alpha(press_alpha)


func _on_mouse_up():
	_set_bg_alpha(hover_alpha if _mouse_entered else idle_alpha)


func _gui_input(event):
	if event.is_action_pressed("interact"):
		pressed.emit()

func _on_pressed():
	if not disabled:
		pressed.emit()


func _process(_delta):
	if not is_visible_in_tree() and _mouse_entered:
		_mouse_entered = false
		_stylebox.bg_color.a = idle_alpha


func set_margins(right, top, left, bottom):
	content.add_theme_constant_override("margin_right", right)
	content.add_theme_constant_override("margin_top", top)
	content.add_theme_constant_override("margin_left", left)
	content.add_theme_constant_override("margin_bottom", bottom)


func set_corner_radius(radius):
	_stylebox.set("corner_radius_top_left", radius)
	_stylebox.set("corner_radius_top_right", radius)
	_stylebox.set("corner_radius_bottom_left", radius)
	_stylebox.set("corner_radius_bottom_right", radius)


func _on_hovered():
	if not disabled:
		_mouse_entered = true
		_set_bg_alpha(hover_alpha)


func _on_unhovered():
	_mouse_entered = false
	_set_bg_alpha(idle_alpha)


func _set_bg_alpha(alpha):
	var from = _stylebox.bg_color
	var to = bg_color
	to.a = alpha

	tween.interpolate_property(
		_stylebox, "bg_color", from, to, 0.1, Threen.TRANS_LINEAR, Threen.EASE_IN_OUT
	)
	tween.start()
