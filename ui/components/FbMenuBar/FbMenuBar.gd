extends Panel

@export var title = "Title":
	set(value):
		title = value
		if title_label:
			title_label.text = value
	get:
		return title

@export var hide_back_btn = false:
	set(value):
		hide_back_btn = value
		if back_btn:
			back_btn.visible = not hide_back_btn
	get:
		return hide_back_btn


@export var disable_back_btn = false:
	set(value):
		disable_back_btn = value
		if back_btn:
			back_btn.disabled = disable_back_btn

@onready var title_label = $Title
@onready var back_btn = $BackButton


func _ready():
	self.title = title
	self.hide_back_btn = hide_back_btn
	self.disable_back_btn = disable_back_btn
	focus_entered.connect(_on_focus_entered)

func _on_focus_entered():
	if hide_back_btn or disable_back_btn:
		return

	back_btn.call_deferred("grab_focus")
	back_btn.call_deferred("grab_click_focus")


func _unhandled_input(event):
	if back_btn.is_visible_in_tree() and event.is_action_pressed("c_cancel"):
		back_btn.press()
		#back_btn.disabled = true
		#FIXME: hack to prevent double backing
		#get_tree().create_timer(1).timeout.connect(back_btn.set_disabled.bind(false))
