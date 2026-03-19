extends Node2D

@onready var la_electrista := $LaElectricista
@onready var globobo := $Globobo
@onready var nasawa := $Nasawa

@onready var sfx_pickup = $pickup
@onready var sfx_drop = $drop


func _ready():
	la_electrista.drag_start.connect(_on_drag_started)
	la_electrista.drag_stop.connect(_on_drag_stopped)
	globobo.drag_start.connect(_on_drag_started)
	globobo.drag_stop.connect(_on_drag_stopped)
	nasawa.drag_start.connect(_on_drag_started)
	nasawa.drag_stop.connect(_on_drag_stopped)


func _on_drag_started():
	sfx_pickup.play()


func _on_drag_stopped():
	sfx_drop.play()
