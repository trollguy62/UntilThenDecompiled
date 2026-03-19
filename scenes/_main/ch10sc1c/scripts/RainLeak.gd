extends MeshInstance3D

const PROP_INSTANCE_PROGRESS = "instance_shader_parameters/progress"

@onready var _particle_drop = $Drop
@onready var _bucket = get_node_or_null("../Bucket")
@onready var _sfx_water_drop_floor = $WaterDropFloor
@onready var _sfx_water_drop_bucket = $WaterDropBucket

func _ready():
	set(PROP_INSTANCE_PROGRESS, 0.0)

	while is_inside_tree():
		await _drop()
		var interval = randf_range(0.6, 1.5)
		await get_tree().create_timer(interval).timeout


func _drop():
	var tween = create_tween()
	tween.tween_property(self, PROP_INSTANCE_PROGRESS, 1.0, 1.0)
	await tween.finished

	_particle_drop.restart()
	_particle_drop.emitting = true

	tween = create_tween()
	tween.tween_property(self, PROP_INSTANCE_PROGRESS, 0.04, 0.08)
	await tween.finished
	await Utils.wait(0.25)
	
	var sfx = _sfx_water_drop_floor
	
	if _bucket and _bucket.visible:
		sfx = _sfx_water_drop_bucket
	
	sfx.play()
