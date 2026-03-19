extends Node3D

const FireworkLight = preload("FireworkLight.gd")
const HEADLIGHT_COLOR = Color("ffdf38")
@export var sprite_paths : Array[NodePath]

var _firework_lights := []
var _sprites := []


func _ready():
	for p in sprite_paths:
		var sprite = get_node_or_null(p)
		assert(sprite is AnimatedPaper3D)
		_sprites.append(sprite)

	for child in get_children():
		if child is FireworkLight:
			_firework_lights.append(child)

	assert(_sprites.size() > 0)
	assert(_firework_lights.size() > 0)


func _process(_delta):
	if not is_visible_in_tree():
		_pass_color(Color.BLACK)
		return

	var max_light_energy = 0.0
	for light in _firework_lights:
		max_light_energy = max(max_light_energy, light.max_light_energy)

	var color = Color.BLACK

	for light in _firework_lights:
		color += light.light_color * (light.light_energy / light.max_light_energy)

	color.a = 1.0
	_pass_color(color)


func _pass_color(color: Color):
	for sprite in _sprites:
		sprite.emission_mult = color

func force_light_colors(color: Color):
	for c in get_children():
		if "light" in c and c.light is Light3D:
			c.light.light_color = color

func reset_light_colors():
	for c in get_children():
		if "reset_color" in c:
			c.reset_color()
