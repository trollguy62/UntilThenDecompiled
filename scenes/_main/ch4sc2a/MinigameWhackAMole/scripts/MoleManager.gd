extends Node2D

signal mole_hit(score)

@export var time_between_rounds: int = 3
@export var min_mole_appearance: int = 2
@export var max_mole_appearance: int = 4

@onready var timer = $Timer
@onready var pop_sfx = $Pop

var used_values = []
var moles: Array = []
var active_moles: Array = []

func _ready():
	timer.timeout.connect(on_timer_timeout)
	get_children_moles()

func start():
	timer.start(time_between_rounds)

func stop():
	timer.stop()
	hide_all_mole()

func hide_all_mole():
	for i in moles.size():
		moles[i].hide_mole()

func on_timer_timeout():
	var mole_count = randi() % max_mole_appearance + min_mole_appearance
	for i in mole_count:
		show_random_mole(0,moles.size())
	used_values.clear()

func get_children_moles():
	for i in self.get_children():
		if i is Mole:
			moles.append(i)
			i.mole_hit.connect(_on_mole_hit)

func show_random_mole(_min,_max):
	var random_value = randi() % _max +_min

	while used_values.has(random_value):
		random_value =  randi() % _max +_min

	used_values.append(random_value)
	moles[random_value].prepare_to_appear()

func _on_mole_hit(score):
	mole_hit.emit(score)

func get_random_active_mole():
	active_moles.clear()

	for i in moles.size():
		if moles[i].is_appear():
			active_moles.append(moles[i])

	if not active_moles.is_empty():
		var rand = randi() % active_moles.size()
		return 	active_moles[rand]
