extends AnimalMovement

@export var fly_speed : float = 2
@export var fly_animations: Array[String]

@onready var animal_animation: = $Sprite/AnimalAnimation

var anim_frame: int = 0
var frame_count: int
var move_right

func _ready():
	super._ready()
	sprite.frame_changed.connect(_on_frame_changed)
	frame_count = sprite.texture_frames.get_frame_count("hop")
	move_right = sprite.flip_h

func _process(delta):
	for anim in fly_animations:
		if anim == sprite.animation:
			path_follow.progress += delta * fly_speed
			sprite.flip_h = true if path_follow.position.x > 0 else false

func _on_frame_changed():
	if sprite.animation == "hop":
		if anim_frame != 0 or anim_frame != 3:
			if move_right == true:
				sprite.position.x += speed
				sprite.flip_h = true
			else :
				sprite.position.x -= speed
				sprite.flip_h = false

	anim_frame += 1

	if (anim_frame >= frame_count):
		anim_frame = 0
		move_right = true if randf() > 0.5 else false

func set_fly_animation():
	animal_animation.stop_animation_cycle()
	Utils.randomize()
	var random_anim = randi_range(0,fly_animations.size()-1)
	sprite.animation = fly_animations[random_anim]
