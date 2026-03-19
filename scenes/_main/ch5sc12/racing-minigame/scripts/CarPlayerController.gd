extends CarController

signal event_emitted(ev)

@export var replayPath : Resource
@export var collision_sounds_enabled = false
@export var collision_sounds = []

var frames = 0
var position_data = []
var rotation_data = []
var vel: float

@onready var ast = $AudioStreamPlayer
@onready var engine_sounds = [$LoEngine,$MidEngine,$HiEngine]
@onready var phys_body = $Ball


func _ready():
	super._ready()
	if collision_sounds_enabled:
		phys_body.contact_monitor = true
		phys_body.body_entered.connect(_on_body_entered)


func _process(delta):
	if not ground_ray.is_colliding():
		return

	process_input()
	rotate_wheels()
	rotate_car(delta)
	align_to_surface(delta)


func _physics_process(delta):
	accelerate()
	play_engine_sound()	


	if Utils.is_internal_debug():
		record_transform()


func process_input():
	speed_input = 0
	rotate_input = 0

	if can_move:
		speed_input += Input.get_action_raw_strength("move_up")
		speed_input -= Input.get_action_raw_strength("move_down")
	speed_input *= acceleration

	if can_move:
		rotate_input += Input.get_action_raw_strength("move_left")
		rotate_input -= Input.get_action_raw_strength("move_right")
	rotate_input *= deg_to_rad(steering)


func record_transform():
	position_data.append(car_mesh.transform.origin)
	rotation_data.append(car_mesh.global_transform)

	if Input.is_action_just_pressed("ui_accept"):
		#save_replay()
		print("replay saved!!")

	frames += 1


func save_replay():
	if replayPath:
		var replay_data = load(replayPath.resource_path)
		replay_data.position_data = position_data.duplicate()
		replay_data.rotation_data = rotation_data.duplicate()
		#ResourceSaver.save(replayPath.resource_path, replay_data)


func play_engine_sound():
	vel = remap(ball.linear_velocity.length(),0,50,0,1)
	
	if vel < 0.30:		
		engine_sounds[0].volume_db =  -16
		engine_sounds[1].volume_db = -80
		engine_sounds[2].volume_db = -80
	elif vel >= 0.30 and vel < 0.60:
		engine_sounds[0].volume_db = -80
		engine_sounds[1].volume_db = -16
		engine_sounds[2].volume_db = -80
	elif vel >= 0.60:
		engine_sounds[0].volume_db = -80
		engine_sounds[1].volume_db = -80
		engine_sounds[2].volume_db = -16
		
func stop_engine_sound():
		engine_sounds[0].stop()
		engine_sounds[1].stop()
		engine_sounds[2].stop()
		
				
#FIXME: sfx like these should be triggered by the signal higher up in the tree
## but is in here for now for quicker implementationd
func _on_body_entered(body):
	if "should_trigger_collision_sound" in body:
		if body.should_trigger_collision_sound and collision_sounds_enabled:
			ast.stream = _get_random_collision_sound()
			ast.volume_db = _get_collision_volume(body)
			ast.play()


func _get_random_collision_sound() -> AudioStream:
	if collision_sounds.size() <= 0:
		printerr("Collision sounds enabled but no assets set!")
		return null
	return collision_sounds[randi() % collision_sounds.size()]


func _get_collision_volume(body):
	#this entire method is not entirely accurate but should be good enough,
	##To accurately determine the impulses created after collision
	##we need to reach into the PhysicsServer and determine contact points, normals etc.:/
	var speed_diff: float
	var v: Vector3 = phys_body.linear_velocity
	var speed: float = v.length()

	if "linear_velocity" in body:
		assert(body.linear_velocity is Vector3)
		var collider_speed: float = 0

		if v.length() <= 0.001:
			# zero case, we're not moving, but they are
			speed_diff = body.linear_velocity.length()
		else:
			collider_speed = (v.dot(body.linear_velocity) / v.dot(v) * v).length()

		speed_diff = abs(speed - collider_speed)  ##this should output higher values when going against the collider
	else:
		speed_diff = v.length()

	#FIXME: consts are in here temporarily
	var MAX_DB = 6
	var MIN_DB = 0
	var MAX_IMPACT_VELOCITY = 60

	#curve is linear for now, but could use a log or exp function
	return remap(speed_diff, 0, MAX_IMPACT_VELOCITY, MIN_DB, MAX_DB)
