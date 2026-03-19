@tool
extends StaticBody2D

signal removed

@export var texture : Texture : set = _set_texture, get = _get_texture

@onready var sprite = $Sprite
@onready var hint = $Hint
@onready var btn = $Button

var removable: bool = true


func _ready():
	btn.pressed.connect(_remove)
	$CollisionShape2D.disabled = true
	self.texture = texture

	if not Engine.is_editor_hint():
		await get_tree().physics_frame
		await get_tree().physics_frame
		_attach()
		$CollisionShape2D.disabled = false


func _set_texture(value):
	texture = value
	if sprite:
		sprite.texture = texture


func _get_texture():
	return texture


func _remove():
	removed.emit()
	btn.disabled = true
		
	if not removable:
		return
	
	for child in get_children():
		if child is PinJoint2D:
			child.queue_free()
	#btn.queue_free()
	$CollisionShape2D.disabled = true
	
	$Sprite.visible = false
	$Pop.play()
	hint.play("pop")

	await hint.animation_finished
	visible = false


func _attach():
	var bodies = $Area2D.get_overlapping_bodies()
	if bodies.is_empty():
		return

	for body in bodies:
		var pin_joint := PinJoint2D.new()
		pin_joint.node_a = body.get_path()
		pin_joint.node_b = self.get_path()
		pin_joint.position = $PinJointTarget.position
		pin_joint.scale = Vector2.ONE * 0.25
		add_child(pin_joint)
