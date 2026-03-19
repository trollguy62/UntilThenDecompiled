@tool
extends Node3D

const COMPONENTS = ["skin", "bottom", "top", "hair"]
const CHAR_NAMES = {Constants.MALE: "NpcMale", Constants.FEMALE: "NpcFemale"}

@export var gen_seed := 23:
	set(value):
		gen_seed = value
		if sprite:
			_generate()

@export var gender := Constants.MALE:
	set(value):
		gender = value
		if sprite:
			_generate()

@export var animation := "walk l":
	set(value):
		animation = value
		if sprite:
			_generate()

@export var flip_h := false:
	set(value):
		flip_h = value
		if sprite:
			sprite.flip_h = flip_h

@export var flip_v := false:
	set(value):
		flip_v = value
		if sprite:
			sprite.flip_v = flip_v

@onready var sprite: AnimatedPaper3D = $Sprite
@onready var colorizer: Colorizer = $Colorizer

const _male_resource = preload("res://components/Npc/Resource/NpcResourceMale.tres")
const _female_resource = preload("res://components/Npc/Resource/NpcResourceFemale.tres")

func _ready():
	_generate()
	sprite.flip_h = flip_h
	sprite.flip_v = flip_v

#NpcMale -> bottom_01/02 -> idle b/l/walk l -> png
#Resource.bottoms[idx]["idle l"]

func _generate():
	var frames = []  # Image[]
	var resource = _male_resource if gender == 0 else _female_resource

	for component in COMPONENTS:
		var subframes = []  # Image[]

		#randomize picking set
		var idx = randi_range(0, resource[component + "s"].size() - 1)
		#get the textures
		var textures = resource[component + "s"][idx][animation]
		for texture in textures:
			subframes.append(texture.get_image())

		#color the set
		for i in range(subframes.size()):
			var subframe: Image = subframes[i]

			colorizer.set_gen_seed(gen_seed)
			colorizer.manipulate(subframe, component, gender)

			if frames.size() < i + 1:
				frames.append(subframe)
			else:
				var frame: Image = frames[i]
				var rect = Rect2(Vector2(), subframe.get_size())
				frame.blend_rect(subframe, rect, Vector2())

	if frames.is_empty():
		return

	var sprite_frames = SpriteFrames.new()
	var speed = _speed_of(animation)

	sprite_frames.add_animation(animation)
	sprite_frames.set_animation_speed(animation, speed)

	for i in range(frames.size()):
		var texture = ImageTexture.create_from_image(frames[i])
		sprite_frames.add_frame(animation, texture)

	sprite.texture_frames = sprite_frames
	sprite.animation = animation
	sprite.frame = randi() % frames.size()

func _speed_of(animation: String) -> float:  # TODO this reeks of temporary-ness
	if animation.begins_with("idle"):
		return 5.0
	elif animation.begins_with("walk"):
		return 7.0
	else:
		return 6.0


func _begin_random(component: String, i: int = 0):
	seed(gen_seed + component.hash() + i * 23)


func _random_int(component: String, i: int = 0) -> int:
	_begin_random(component, i)
	return randi()


func _random_float(component: String, i: int = 0) -> float:
	_begin_random(component, i)
	return randf()

func _random_color(
	component: String,
	i: int = 0,
	h0: float = 0,
	h1: float = 1,
	s0: float = 0,
	s1: float = 0.5,
	v0: float = 0.4,
	v1: float = 0.9
) -> Color:
	_begin_random(component, i)
	var c = Color.WHITE
	c.v = randf_range(v0, v1)
	c.s = randf_range(s0, s1)
	c.h = randf_range(h0, h1)
	return c
