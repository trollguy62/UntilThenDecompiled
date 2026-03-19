extends Control

const default_thumbnail = preload("res://assets/pictures/scene_dir_thumbnails/default.png")

@export var metadata := {}
@export_range(0.0, 1.0) var idle_alpha := 0.0
@export_range(0.0, 1.0) var focus_alpha := 0.1
@export_range(0.0, 1.0) var press_alpha := 0.15

@onready var tween = Threen.new()
@onready var thumbnail = $Margin/HBox/Thumbnail
@onready var title = $Margin/HBox/Title
@onready var click_area = $ClickArea

var _stylebox_hoop: StyleBoxFlat
var _thumbnail_material: ShaderMaterial

var _scene_key: String
var _scene_name: String


func _ready():
	add_child(tween)

	_scene_key = metadata.key
	_scene_name = metadata.get("name", "(No title)")

	click_area.mouse_entered.connect(_on_mouse_entered)
	click_area.focus_entered.connect(_on_focus_entered)
	click_area.mouse_exited.connect(_on_mouse_exited)
	click_area.focus_exited.connect(_on_focus_exited)
	click_area.button_down.connect(_on_button_down)
	click_area.button_up.connect(_on_button_up)
	click_area.pressed.connect(_on_pressed, CONNECT_ONE_SHOT)

	Game.config.debug_unlock_all_scenes_changed.connect(_update_lock_state)

	_stylebox_hoop = get_theme_stylebox("panel").duplicate()
	_stylebox_hoop.bg_color.a = idle_alpha
	add_theme_stylebox_override("panel", _stylebox_hoop)

	_thumbnail_material = thumbnail.material.duplicate()
	thumbnail.material = _thumbnail_material
	_set_thumbnail(default_thumbnail)

	title.text = _scene_name

	_load_thumbnail()
	_update_lock_state()

func _process(delta):
	thumbnail.material.set_shader_parameter("modulate", modulate)

func _update_lock_state():
	var unlocked = Game.savegame.is_scene_unlocked(_scene_key)

	modulate.a = 1.0 if unlocked else 0.5
	_thumbnail_material.set_shader_parameter("enabled", not unlocked)

	click_area.disabled = not unlocked
	click_area.mute_tick = not unlocked
	click_area.focus_mode = Control.FOCUS_ALL if unlocked else Control.FOCUS_NONE


func _load_thumbnail():
	var path = "res://assets/pictures/scene_dir_thumbnails/%s.png" % _scene_key
	if ResourceLoader.exists(path):
		_set_thumbnail(load(path))


func _set_thumbnail(tex: Texture):
	thumbnail.texture = tex
	_thumbnail_material.set_shader_parameter("tex", tex)


func _on_mouse_entered():
	if click_area.disabled:
		return
	_on_focus_entered()


func _on_focus_entered():
	if click_area.disabled:
		return
	_anim_alpha(focus_alpha)


func _on_mouse_exited():
	if click_area.disabled:
		return
	if not _is_focused():
		_on_focus_exited()


func _on_focus_exited():
	if click_area.disabled:
		return
	_anim_alpha(idle_alpha)


func _on_button_down():
	if click_area.disabled:
		return
	_anim_alpha(press_alpha)


func _on_button_up():
	if click_area.disabled:
		return
	_anim_alpha(focus_alpha if _is_focused() else idle_alpha)


func _is_focused() -> bool:
	return click_area == get_viewport().gui_get_focus_owner()


func _on_pressed():
	Game.to_scene_key(_scene_key)


func _anim_alpha(a: float):
	var from := _stylebox_hoop.bg_color
	var to := from
	to.a = a

	tween.interpolate_property(_stylebox_hoop, "bg_color", from, to, 0.1)
	tween.start()
