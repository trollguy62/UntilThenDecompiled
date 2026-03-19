extends "res://ui/screens/Screen.gd"

const Set = preload("res://data/Set.gd")
const Email = preload("res://data/Email.gd")

const ic_close = preload("res://assets/ui/ic_close.png")
const ic_back = preload("res://assets/ui/ic_back.png")

@export var ids := []
@export var controller_accidental_close_tolerance_count := 0

@onready var content = $ScrollContainer/MarginContainer/EmailContent
@onready var prev_btn = $Panel/HBoxContainer/Prev
@onready var next_btn = $Panel/HBoxContainer/Next
@onready var next_btn_texture = next_btn.child
@onready var scroll = $ScrollContainer
@onready var spinner = $ScrollContainer/MarginContainer/Spinner
@onready var _close_counter = controller_accidental_close_tolerance_count

var _emails := []
var _emails_loaded := Set.new()
var _idx := -1


func _enter_tree():
	self.bg_color = Color(1, 1, 1, 0.75)


func _ready():
	content.visible = false
	spinner.visible = false

	prev_btn.pressed.connect(_on_prev_btn_pressed)
	next_btn.pressed.connect(_on_next_btn_pressed)

	for id in ids:
		var email_json = Store.get_value("email://%s" % id)
		if email_json:
			var email = Email.new(email_json)
			_emails.append(email)
	_set_idx(0)


func _enter():
	#preserves close counter across multiple email screen invocations
	#ideally should be in a reset function somewhere
	_close_counter = controller_accidental_close_tolerance_count


func _set_idx(idx: int):
	if _idx == idx or idx < 0 or idx >= _emails.size():
		return

	_idx = idx
	content.visible = false
	spinner.visible = true
	prev_btn.visible = false
	next_btn.visible = false

	await Utils.wait(randf_range(0.2, 0.8))

	prev_btn.visible = idx > 0
	next_btn.visible = true
	next_btn_texture.texture = ic_close if idx == _emails.size() - 1 else ic_back

	content.email = _emails[idx]
	scroll.scroll_now_to(Vector2.ZERO)

	content.visible = true
	spinner.visible = false


func press_prev():
	_on_prev_btn_pressed()


func press_next():
	if _idx == _emails.size() - 1 and _close_counter > 0:
		_close_counter -= 1
	else:
		_on_next_btn_pressed()


func _on_prev_btn_pressed():
	_set_idx(_idx - 1)


func _on_next_btn_pressed():
	if _idx == _emails.size() - 1:
		navigator.pop()
	else:
		_set_idx(_idx + 1)


func _unhandled_input(event):
	if event.is_action_pressed("c_back"):
		if prev_btn.visible:
			press_prev()

	if event.is_action_pressed("c_next"):
		if next_btn.visible and _idx < _emails.size() - 1:
			press_next()

	if event.is_action_pressed("c_cancel"):
		if next_btn.visible and _idx == _emails.size() - 1:
			press_next()
