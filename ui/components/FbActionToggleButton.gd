extends Button

const FbQuark = preload("res://data/fb/FbQuark.gd")
const FbAtom = preload("res://data/fb/FbAtom.gd")

const ANIM_DUR = 0.3

const ACTION_LIKE = 0
const ACTION_SHARE = 1

@onready var tween = Threen.new()

@export_range(0, 1) var action_code = 0
@export var icon_child_index: int = -1
@export var color_inactive = FbQuark.COLOR_STAT_INACTIVE
@export var color_active = FbQuark.COLOR_STAT_ACTIVE

var atom: FbAtom:
	set = _set_atom,
	get = _get_atom

var _action_code: int  # Prevents change to action_code during runtime
var _prop_name = ""
var _checker: DirtyChecker


func _ready():
	add_child(tween)
	pressed.connect(_on_pressed)
	_action_code = action_code

	_prop_name = {ACTION_LIKE: "liked", ACTION_SHARE: "shared"}[_action_code]

	self.atom = atom


func _set_atom(value):
	var old_atom = atom
	atom = value

	if old_atom:
		_checker.changed.disconnect(_on_active_changed)
		_checker.queue_free()
	if tween and atom:
		modulate = color_active if _is_active() else color_inactive
		_checker = DirtyChecker.new(atom, _prop_name)
		_checker.changed.connect(_on_active_changed)
		add_child(_checker)

func press():
	_on_pressed()

func _get_atom():
	return atom

func _on_pressed():
	if atom != null:
		atom[_prop_name] = not _is_active()


func _is_active():
	return atom[_prop_name]


func _on_active_changed():
	var active = _is_active()
	var color1 = color_active if active else color_inactive
	var scale1 = Vector2.ONE * 1.2
	var icon = self

	if icon_child_index >= 0 and icon_child_index < get_child_count():
		icon = get_child(icon_child_index)
	icon.pivot_offset = icon.size / 2

	tween.interpolate_property(self, "modulate", modulate, color1, ANIM_DUR)
	tween.interpolate_property(
		icon,
		"scale",
		icon.scale,
		scale1,
		ANIM_DUR / 2,
		Threen.TRANS_CUBIC,
		Threen.EASE_IN_OUT
	)
	tween.start()
	await Utils.wait(ANIM_DUR / 2)

	tween.interpolate_property(
		icon,
		"scale",
		icon.scale,
		Vector2.ONE,
		ANIM_DUR / 2,
		Threen.TRANS_CUBIC,
		Threen.EASE_IN_OUT
	)
	tween.start()
	await tween.tween_completed

func _gui_input(event):
	#preserves parity with old behavior (before controller support was added)
	if event is InputEventMouse:
		add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	else:
		remove_theme_stylebox_override("focus")
