extends Control

signal bg_color_changed

const Modal = preload("res://ui/modals/Modal.gd")
const ModalHandler = preload("res://ui/components/ModalHandler/ModalHandler.tscn")
const FocusableControl = preload("res://ui/components/Game/FocusableControl.gd")

@onready var modal_handler = ModalHandler.instantiate()

@export var persist_focus := false
@export var focus_on_enter: Control
@export var disable_focus_enter_on_no_controller = false
@export var default_back_btn: Control

var _persist_focus_control: Control

var navigator
var meta := {}

var bg_color: Color = Color(0, 0, 0, 0.7):
	set(value):
		bg_color = value
		bg_color_changed.emit()
	get:
		return bg_color

func _ready():
	if default_back_btn and "disabled" in default_back_btn:
		default_back_btn.disabled = true

func _mount():
	if not modal_handler.is_inside_tree():
		add_child(modal_handler)


func _before_show():
	pass


func _after_show():
	if default_back_btn and "disabled" in default_back_btn:
		default_back_btn.disabled = false

	var new_focus: Control

	if persist_focus and _persist_focus_control != null:
		new_focus = _persist_focus_control
	else:
		new_focus = focus_on_enter

	if modal_handler._current_modal != null:
		await get_tree().process_frame
		modal_handler._current_modal.call_deferred("grab_focus")

	elif new_focus != null:
		if new_focus is FocusableControl:
			new_focus.mute_next_tick_only = true
		if not (Input.get_connected_joypads().is_empty() and disable_focus_enter_on_no_controller):
			new_focus.call_deferred("grab_focus")




func _before_hide():
	if default_back_btn and "disabled" in default_back_btn:
		default_back_btn.disabled = true
	if persist_focus:
		_persist_focus_control = get_viewport().gui_get_focus_owner()


func _after_hide():
	pass


func _unmount():
	pass


func _push_named(path: String) -> bool:
	return false


func reveal_modal(modal: Modal):
	for c in get_children():
		c.hide()
	modal.dismissed.connect(_on_modal_dismissed, CONNECT_ONE_SHOT)
	modal_handler.reveal(modal, self)


func dismiss_modal():
	modal_handler.dismiss()

func _on_modal_dismissed(return_value):
	for c in get_children():
		c.show()

	if persist_focus:
		_persist_focus_control.grab_focus()
	elif focus_on_enter:
		focus_on_enter.grab_focus()

	print("modal_dismissed")
