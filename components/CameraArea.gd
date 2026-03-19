extends Area3D

const SceneManager = preload("res://components/SceneManager.gd")

@export var enabled: float = true
@export var shot: String = ""

@onready var scene_manager = Service.of("SceneManager") as SceneManager

var _entered_areas := Set.new()  # Set<Area3D>
var _last_shot := ""


func _ready():
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)


func _on_area_entered(area: Area3D):
	_entered_areas.add(area)
	_last_shot = scene_manager.shot

	if enabled and _entered_areas.size() > 0 and _last_shot != shot:
		scene_manager.shot = shot


func _on_area_exited(area: Area3D):
	_entered_areas.remove(area)

	if enabled and _entered_areas.is_empty() and scene_manager.shot == shot:
		scene_manager.shot = _last_shot
