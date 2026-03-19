extends CanvasLayer

const DEFAULT_DURATION = 1.0

@onready var fader = $Fader
@onready var focus = $Focus
@onready var tween = Threen.new()

func _ready():
	add_child(tween)
	focus.focus_name = "Fader"


func _process(_delta):
	var is_blocking = fader.modulate.a > 0
	var new_mouse_filter = Control.MOUSE_FILTER_STOP if is_blocking else Control.MOUSE_FILTER_IGNORE

	if new_mouse_filter != fader.mouse_filter:
		fader.mouse_filter = new_mouse_filter
	# Don't let go of focus even when cleared by Game
	if is_blocking:
		focus.push()
	else:
		focus.pop()


func fade_in(duration = DEFAULT_DURATION, delay = 0):
	await _fade(true, duration, delay)


func fade_out(duration = DEFAULT_DURATION, delay = 0):
	await _fade(false, duration, delay)


func fade_between(
	fn: Callable, duration = DEFAULT_DURATION, between_delay = 0.5
):
	await fade_out(duration)
	await fn.call()
	await Utils.wait(between_delay)
	await fade_in(duration)


func _fade(into: bool, duration: float, delay: float):
	var modulate = Color(0, 0, 0, 0) if into else Color.BLACK

	if delay > 0:
		await Utils.wait(delay)

	tween.interpolate_property(fader, "modulate", fader.modulate, modulate, duration)
	tween.start()
	await tween.tween_completed
