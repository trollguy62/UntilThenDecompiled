extends Control

const FreeLookCam = preload("res://components/FreeLookCam/FreeLookCam.gd")

@onready var camera: FreeLookCam = get_parent()
# Camera tab
@onready var lock_rot = $Camera/LockRotCheckBox
@onready var fov = $Camera/FovHSlider
@onready var move_speed = $Camera/MoveSpeedHSlider
@onready var pan_speed = $Camera/PanSpeedHSlider
@onready var mouse_sens = $Camera/MouseSensHSlider
@onready var near_clip = $Camera/NearClipHSlider
@onready var far_clip = $Camera/FarClipHSlider
# Graphics tab
@onready var ssr = $Graphics/SsrCheckBox
@onready var ssao = $Graphics/SsaoCheckBox
@onready var glow = $Graphics/GlowCheckBox
@onready var glow_fac = $Graphics/GlowFacHSlider
# DoF tab
@onready var near = $DoF/NearCheckBox
@onready var near_dist = $DoF/NearDistHSlider
@onready var near_trans = $DoF/NearTransHSlider
@onready var far = $DoF/FarCheckBox
@onready var far_dist = $DoF/FarDistHSlider
@onready var far_trans = $DoF/FarTransHSlider
@onready var dof_amount = $DoF/AmountHSlider


func _ready():
	visible = false

	lock_rot.toggled.connect(_set_camera_prop.bind("lock_rotation"))
	fov.value_changed.connect(_set_camera_prop.bind("fov"))
	move_speed.value_changed.connect(_set_camera_prop.bind("move_speed"))
	pan_speed.value_changed.connect(_set_camera_prop.bind("pan_speed"))
	mouse_sens.value_changed.connect(_set_camera_prop.bind("mouse_sensitivity"))
	near_clip.value_changed.connect(_set_camera_prop.bind("near"))
	far_clip.value_changed.connect(_set_camera_prop.bind("far"))

	ssr.toggled.connect(_set_env_prop.bind("ssr_enabled"))
	ssao.toggled.connect(_set_env_prop.bind("ssao_enabled"))
	glow.toggled.connect(_set_env_prop.bind("glow_enabled"))
	glow_fac.value_changed.connect(_set_env_prop.bind("glow_intensity"))

	near.toggled.connect(_set_camera_attrs_prop.bind("dof_blur_near_enabled"))
	near_dist.value_changed.connect(_set_camera_attrs_prop.bind("dof_blur_near_distance"))
	near_trans.value_changed.connect(_set_camera_attrs_prop.bind("dof_blur_near_transition"))
	far.toggled.connect(_set_camera_attrs_prop.bind("dof_blur_far_enabled"))
	far_dist.value_changed.connect(_set_camera_attrs_prop.bind("dof_blur_far_distance"))
	far_trans.value_changed.connect(_set_camera_attrs_prop.bind("dof_blur_far_transition"))
	dof_amount.value_changed.connect(_set_camera_attrs_prop.bind("dof_blur_amount"))


func _input(ev):
	if ev is InputEventKey:
		if ev.pressed and not ev.echo and ev.keycode == KEY_PERIOD:
			_toggle()


func _toggle():
	if not camera.is_enabled():
		return

	if visible == Game.paused:
		var paused = not Game.paused
		Game.paused = paused
		visible = paused

		if visible:
			_load()


func _load():
	var env: Environment = camera.environment

	lock_rot.button_pressed = camera.lock_rotation
	fov.value = camera.fov
	move_speed.value = camera.move_speed
	pan_speed.value = camera.pan_speed
	mouse_sens.value = camera.mouse_sensitivity
	near_clip.value = camera.near
	far_clip.value = camera.far

	ssr.button_pressed = env.ssr_enabled
	ssao.button_pressed = env.ssao_enabled
	glow.button_pressed = env.glow_enabled
	glow_fac.value = env.glow_intensity

	near.button_pressed = camera.attributes.dof_blur_near_enabled
	near_dist.value = camera.attributes.dof_blur_near_distance
	near_trans.value = camera.attributes.dof_blur_near_transition
	far.button_pressed = camera.attributes.dof_blur_far_enabled
	far_dist.value = camera.attributes.dof_blur_far_distance
	far_trans.value = camera.attributes.dof_blur_far_transition
	dof_amount.value = camera.attributes.dof_blur_amount


func _set_camera_prop(value, prop):
	camera[prop] = value


func _set_env_prop(value, prop):
	camera.environment[prop] = value


func _set_camera_attrs_prop(value, prop):
	camera.attributes[prop] = value
