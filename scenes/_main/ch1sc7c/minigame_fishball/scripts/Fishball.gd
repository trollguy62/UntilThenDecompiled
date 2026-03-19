extends RigidBody2D

const CLASS_NAME = "Fishball"

@export var sprite_variants : Array[Texture]

@onready var sprite = $Sprite


func _ready():
	add_to_group("fishballs")
	freeze = true

	var texture = sprite_variants[randi() % sprite_variants.size()]
	sprite.texture = texture
	sprite.material = sprite.material.duplicate()
	sprite.material.set_shader_parameter("texture_albedo", texture)


func awake():
	freeze = false


func stick(new_parent: Node):
	var global_transform = self.global_transform
	reparent(new_parent)
	self.global_transform = global_transform
	freeze = true


func get_class_name() -> String:
	return CLASS_NAME

static func get_fishball_of(area: Area2D):
	var parent = area.get_parent()
	if parent is RigidBody2D and parent.get_class_name() == CLASS_NAME:
		return parent
