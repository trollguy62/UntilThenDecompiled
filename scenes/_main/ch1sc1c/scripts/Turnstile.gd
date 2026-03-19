extends Node3D

@export var ooo := false  # Out of order

@export var em_go: Texture
@export var em_wait: Texture
@export var em_ooo: Texture

@onready var body = $Body
@onready var trigger_area = $TriggerArea
@onready var timer = $Timer

@onready var material = body.material_override.duplicate() as ShaderMaterial


func _ready():
	body.material_override = material

	trigger_area.area_entered.connect(_on_area_entered)


func _process(delta):
	var em = em_ooo if ooo else em_go

	if not ooo and timer.time_left > 0:
		em = em_wait

	material.set_shader_parameter("texture_emission", em)


func _on_area_entered(area: Area2D):
	timer.start(2.0)
