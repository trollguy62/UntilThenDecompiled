extends Area2D

@export var textures: Array[Texture]
@export var speed = 10
@export var enabled = false:
	set(v):
		enabled = v


@onready var target_position = global_position
@onready var sprite = $Sprite2D


func _ready():
	sprite.texture = get_random_texture()
	$Timer.timeout.connect(_on_timer_timeout)

func _process(delta):
	if (target_position - global_position).length_squared() > 0.2:
		global_position += (target_position - global_position) * delta * speed

func get_random_postion():
	var resolution = Vector2()
	resolution.x = ProjectSettings.get_setting("display/window/size/viewport_width")
	resolution.y = ProjectSettings.get_setting("display/window/size/viewport_height")
	return Vector2(randf_range(0.0, resolution.x), randf_range(0.0, resolution.y))

func get_random_texture():
	if textures.size() == 0:
		return null
	return textures[randi_range(0, textures.size() - 1)]

func _on_timer_timeout():
	#target_position = get_random_postion()
	sprite.texture = get_random_texture()

func relocate():
	target_position = get_random_postion()

func fade():
	$AnimationPlayer.play("fade")
