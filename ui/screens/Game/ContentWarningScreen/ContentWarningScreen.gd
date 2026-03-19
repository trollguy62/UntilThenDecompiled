extends PanelContainer

signal exited(show_list: bool)
signal _internal_exited(show_list: bool)

@export var fade_duration = 1.0

@onready var warning = $MarginContainer/Warning
@onready var controls = $Controls


func _ready():
	warning.modulate.a = 0
	controls.modulate.a = 0
	
	set_process(false)
	
	var tween = create_tween()
	tween.tween_property(warning, "modulate:a", 1, fade_duration)
	tween.tween_interval(2)
	tween.tween_property(controls, "modulate:a", 1, fade_duration)
	await tween.finished
	
	set_process(true)
	var show_list = await _internal_exited
	set_process(false)
	
	tween = create_tween()
	tween.set_parallel()
	tween.tween_property(warning, "modulate:a", 0, fade_duration)
	tween.tween_property(controls, "modulate:a", 0, fade_duration)
	await tween.finished
	
	exited.emit(show_list)


func _process(_delta):
	if Input.is_action_just_pressed("choice_1"):
		# Show list
		_internal_exited.emit(true)
	elif Input.is_action_just_pressed("choice_2"):
		# Skip always
		Game.config.skip_content_warning = true
		Game.save_config()
		_internal_exited.emit(false)
	elif Input.is_action_just_pressed("choice_3") or Input.is_action_just_pressed("pause"):
		# Skip for now
		_internal_exited.emit(false)
