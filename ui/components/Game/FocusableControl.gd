extends Button

@export var mute_tick := false
@export var mute_next_tick_only := false

@onready var tick = AudioStreamPlayer.new()


func _ready():
	tick.stream = preload("res://ui/sfx/tick.wav")
	tick.bus = &"UI"
	add_child(tick)

	mouse_entered.connect(grab_focus)
	focus_entered.connect(_on_focus_entered)


func _on_focus_entered():
	if not _should_mute_tick():
		tick.play()


func _should_mute_tick() -> bool:
	if mute_next_tick_only:
		mute_next_tick_only = false
		return true
	return mute_tick
