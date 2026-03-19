extends OptionButton

@export var mute_tick := false
@export var mute_next_tick_only := false

@onready var tick = AudioStreamPlayer.new()

var popup_menu : PopupMenu

func _ready():
	popup_menu = get_popup()
	tick.stream = preload("res://ui/sfx/tick.wav")
	tick.bus = &"UI"
	add_child(tick)

	mouse_entered.connect(grab_focus)
	focus_entered.connect(_on_focus_entered)
	popup_menu.window_input.connect(_on_window_input)

func _on_focus_entered():
	if not _should_mute_tick():
		tick.play()

func _on_window_input(event):
	if event.is_action_pressed("ui_cancel"):
		popup_menu.hide()

func _should_mute_tick() -> bool:
	if mute_next_tick_only:
		mute_next_tick_only = false
		return true
	return mute_tick
