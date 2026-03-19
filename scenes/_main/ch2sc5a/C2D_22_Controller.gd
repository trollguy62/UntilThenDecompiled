extends Node2D

@onready var chopin := $Interactives/Chopin
@onready var grieg := $Interactives/Grieg
@onready var bach := $Interactives/Bach

@onready var sfx_pickup = $pickup
@onready var sfx_drop = $drop


func _ready():
	chopin.drag_start.connect(_on_drag_started)
	chopin.drag_stop.connect(_on_drag_stopped)
	grieg.drag_start.connect(_on_drag_started)
	grieg.drag_stop.connect(_on_drag_stopped)
	bach.drag_start.connect(_on_drag_started)
	bach.drag_stop.connect(_on_drag_stopped)


func _on_drag_started():
	sfx_pickup.play()


func _on_drag_stopped():
	sfx_drop.play()
