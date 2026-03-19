extends Control

const HeaderLabel = preload("res://scenes/_cutscenes/credits/HeaderLabel.tscn")
const MemberLabel = preload("res://scenes/_cutscenes/credits/MemberLabel.tscn")
const RTL = preload("res://scenes/_cutscenes/credits/RTL.tscn")


@export var use_flow = true
@onready var grid = $HBoxContainer/VBoxContainer/Content
@onready var fc = $VBoxContainer/FlowContainer
@onready var top_level_container_grid = $HBoxContainer
@onready var top_level_container_flow = $VBoxContainer

var header_text: String = ""
var content: Array = [] #[section]{title, members}

func _ready():

	_clear()
	_setup()

func _clear():
	for c in fc.get_children():
		c.queue_free()
	for c in grid.get_children():
		c.queue_free()

func _setup():
	if use_flow:
		_setup_flow()
	else:
		_setup_grid()

func _setup_flow():
	var header_lbl = $VBoxContainer/Header
	header_lbl.text = header_text
	top_level_container_flow.visible = true

	for control in content:
		fc.add_child(control)

func _setup_grid():
	var header_lbl = $HBoxContainer/VBoxContainer/Header
	header_lbl.text = header_text
	top_level_container_grid.visible = true

	for control in content:
		grid.add_child(control)

	grid.columns = min(content.size(), 3)
