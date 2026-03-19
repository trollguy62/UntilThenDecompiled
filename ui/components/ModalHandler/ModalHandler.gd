extends Panel

const Modal = preload("res://ui/modals/Modal.gd")
const Screen = preload("res://ui/screens/Screen.gd")

@onready var tween = Threen.new()
@onready var dismiss_area = $DismissArea

var _current_modal: Modal
var _parent_screen: Screen
var _navigator = Service.of("ScreenNavigator")

func _ready():
	add_child(tween)
	dismiss_area.pressed.connect(_on_dismiss_area_pressed)
	_navigator.screen_pushed.connect(_on_navigator_screen_changed)
	_navigator.screen_popped.connect(_on_navigator_screen_changed)


func reveal(modal: Modal, parent_screen = null):
	dismiss()
	_current_modal = modal
	if parent_screen != null:
		_parent_screen = parent_screen

	if _current_modal == null:
		return

	add_child(_current_modal)
	_current_modal.bg_color_changed.connect(_sync_modal_bg_color)
	_current_modal._reveal(self)

	_sync_modal_bg_color()
	visible = true
	_current_modal.focus_on_enter.grab_focus()
	await _fade(false)


func dismiss():
	var modal = _current_modal

	if modal:
		modal._dismiss()
		modal.bg_color_changed.disconnect(_sync_modal_bg_color)
		await _fade(true)
		remove_child(modal)
		modal.queue_free()

	_current_modal = null
	visible = false


func _fade(out: bool):
	var c = [Color.WHITE, Color.TRANSPARENT]
	if not out:
		c.reverse()

	tween.interpolate_property(self, "modulate", c[0], c[1], 0.1, Threen.TRANS_LINEAR, Threen.EASE_IN)
	tween.start()
	await tween.tween_completed


func _sync_modal_bg_color():
	if _current_modal:
		var stylebox = get_theme_stylebox("panel")
		var from = stylebox.bg_color
		var to = _current_modal.bg_color

		tween.interpolate_property(
			stylebox, "bg_color", from, to, 0.1, Threen.TRANS_LINEAR, Threen.EASE_IN
		)
		tween.start()


func _on_dismiss_area_pressed():
	if _current_modal and _current_modal.cancelable:
		dismiss()

func _on_navigator_screen_changed():
	#FIXME: spaghetti
	if _current_modal == null:
		return
	if _navigator.top() != null:
		#print(_navigator.top().name, " +", _parent_screen.name)
		visible = _navigator.top() == _parent_screen

	_current_modal.focus_on_enter.grab_focus()

func is_modal_focused():
	if _navigator.top() == null or _parent_screen == null or _current_modal == null:
		print("modal not focused*")
		return false
	return _navigator.top() == _parent_screen and _current_modal.is_visible_in_tree()
