extends TextureButton

@onready var tween = Threen.new()

var _is_mouse_entered = false
var _old_disabled


func _ready():
	add_child(tween)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	_old_disabled = disabled
	_refresh()


func _on_mouse_entered():
	_is_mouse_entered = true
	_refresh()


func _on_mouse_exited():
	_is_mouse_entered = false
	_refresh()


func _refresh():
	var to = modulate
	to.a = 80
	if not disabled:
		to.a = 255 if _is_mouse_entered else 230
	to.a /= 255.0

	tween.interpolate_property(
		self, "modulate", modulate, to, 0.1, Threen.TRANS_LINEAR, Threen.EASE_IN_OUT
	)
	tween.start()


func _process(delta):
	if _old_disabled != disabled:
		_old_disabled = disabled
		_refresh()
