extends Node2D

signal wrong_stick
signal correct_stick
signal finished

@export var distance_threshold = 20#px

@onready var _total_targets: int = $Targets.get_children().size()
@onready var _focus = $Focus


var _correct_count: int = 0:
	set(v):
		_correct_count = v
		if _correct_count >= _total_targets:
			finished.emit()

var _finished_tack_ids := []


func _ready():
	for target in $Targets.get_children():
		target.correct_stick.connect(_on_correct_stick)
		target.wrong_stick.connect(emit_signal.bind("wrong_stick"))

	for tack in $Tacks.get_children():
		tack.selected.connect(_on_tack_selected.bind(tack))
		tack.deselected.connect(_on_tack_deselected.bind(tack))
		tack.set_input(false)

	_focus.active_changed.connect(func(active):
		for tack in $Tacks.get_children():
			tack.set_input(active and not tack.id in _finished_tack_ids)
	)


func start():
	show()
	_focus.push()
	#$AnimationPlayer.play("fade_in")


func _on_correct_stick():
	correct_stick.emit()
	_correct_count += 1


func _on_tack_selected(tack):
	tack.z_index = 1


func _on_tack_deselected(tack):
	tack.z_index = 0
	for target in $Targets.get_children():
		if target.id != tack.id:
			continue

		var dist = target.global_position.distance_to(tack.global_position)
		if  dist <= distance_threshold:
			animate(tack, target.global_position)
			tack.set_input(false)
			_finished_tack_ids.append(tack.id)
			correct_stick.emit()
			_correct_count += 1
			return
	animate(tack, tack.start_pos)
	wrong_stick.emit()


func animate(node: Node2D, to: Vector2):
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(node, "global_position", to, 0.5)
