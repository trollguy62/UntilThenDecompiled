extends Node

@export var state_container_alias: String
@export var min_duration : float = 0.2
@export var max_duration : float = 1.0
@export var strength : Array[float] = [0,0.4]

@onready var sprite = get_parent()
@onready var tween = Threen.new()

var state: StateContainer
var enabled: bool


func _ready():
	add_child(tween)
	tween.tween_all_completed.connect(_on_tween_completed)
	state = Utils.get_state_container_of(state_container_alias) as StateContainer
	state.changed.connect(_on_state_changed)


func _on_state_changed():
	enabled = state.dict.get_value("start_glitch", false)
	
	if enabled and not tween.is_active():
		start_glitch()
	elif not enabled and tween.is_active():
		tween.stop_all()
		sprite.glitch_fac = 0


func start_glitch():
	var dur = randf_range(min_duration,max_duration)
	tween.interpolate_property(sprite,"glitch_fac",strength[0],strength[1],dur,Threen.TRANS_LINEAR,Threen.EASE_IN,0.1)
	tween.start()


func _on_tween_completed():
	strength.reverse()
	start_glitch()
