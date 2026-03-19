extends Sprite2D

signal clicked

@export var short_knot: String
@export var story_signal = ""
@export var bring_to_front_on_clicked := false
@export var dissolve_after_short := true

@onready var tween := Threen.new()
@onready var area = $Area2D
@onready var scene_manager = Service.of("SceneManager") as SceneManager

@export var enabled := true

var _mouse_entered := false


func _ready():
	add_child(tween)
	area.mouse_entered.connect(_on_mouse_entered)
	area.mouse_exited.connect(_on_mouse_exited)


func _input(ev: InputEvent):
	if not enabled:
		return

	if ev is InputEventMouseButton:
		if not ev.pressed and _mouse_entered:
			get_viewport().set_input_as_handled()
			_on_clicked()
			if bring_to_front_on_clicked:
				_bring_to_front()


func _bring_to_front():
	var parent = get_parent()
	var position = parent.get_child_count() - 1
	parent.move_child(self, position)


func _on_Area2D_input_event(viewport, event, shape_idx):
	if not enabled:
		return

	if event is InputEventMouseButton:
		if event.pressed:
			_on_clicked()
			if bring_to_front_on_clicked:
				_bring_to_front()


func _on_clicked():
	clicked.emit()
	enabled = false
	var call
	if story_signal != "":
		Story.emit(story_signal)
	if short_knot != "" and scene_manager:
		await _start_short()


	if dissolve_after_short:
		self.enabled = false
		area.input_pickable = false
		tween.interpolate_property(self, "self_modulate", self_modulate, Color.TRANSPARENT, 1)
		tween.start()
		await tween.tween_completed
		queue_free()


func _start_short():
	await scene_manager.start_short(short_knot)


func _on_mouse_entered():
	_mouse_entered = true


func _on_mouse_exited():
	_mouse_entered = false
