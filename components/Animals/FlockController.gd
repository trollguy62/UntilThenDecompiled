extends Node

@export var birds : Array[Node3D]
@export var destroy_time : float  = 5

@onready var area = $Area3D
@onready var timer : Timer =  $Timer
@onready var fly_sound  = $BirdsFly

func _ready():
	area.area_entered.connect(_on_area_entered)
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	
func _on_area_entered(area):
	for bird in birds:
		bird.set_fly_animation()
	fly_sound.play()	
	timer.start(destroy_time)
	
func _on_timer_timeout():
	queue_free()

