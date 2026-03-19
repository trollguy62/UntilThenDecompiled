extends Sprite2D

@export var textures: Dictionary = {"cars": [], "scenery": [], "sexy": []}

@export var off_texture: Texture
@export var minimum_change_time: float = 8.0  #seconds
@export var maximum_change_time: float = 15.0  #seconds
@export var max_zoom: Vector2 = Vector2(5.0, 5.0)
@export var min_zoom: Vector2 = Vector2(4.0, 4.0)
@export var pan_from_center = true

@onready var _og_pos = position
@onready var _og_scale = Vector2(4.0, 4.0)
@onready var tween := Threen.new()
@onready var _renew_timer := $RenewTimer

var display_size: Vector2

var _t: float = 0
var _current_set: String = ""
var _keys: Array = []  # Array<String>
var _set_order: Array = []  # Array<int>
var _set_order_index: int = 0
var _last_anim: int = -1


func _ready():
	add_child(tween)
	_renew_timer.timeout.connect(_renew_display)
	_renew_display()


func _renew_display():
	await get_tree().process_frame
	Utils.randomize()
	var change_time = _get_random_change_time()
	_renew_timer.wait_time = change_time

	if _current_set != "" and _set_order_index < _set_order.size() - 1:
		_set_order_index += 1
	else:
		_change_set()
		_set_order_index = 0

	var set_index = _set_order[_set_order_index]
	texture = textures[_current_set][set_index]
	_renew_timer.start()
	_animate(change_time)


func _get_random_change_time():
	return minimum_change_time + randf() * (maximum_change_time - minimum_change_time)


func _get_random_set() -> String:
	var set_count = textures.size()
	return textures.keys()[randi() % set_count]


func _change_set():
	var _new_set = _get_random_set()
	while _new_set == _current_set:
		_new_set = _get_random_set()

	_set_order = range(textures[_new_set].size())
	_set_order.shuffle()

	_current_set = _new_set


# Pan (any of the 8 directions: left, up, left-up, etc.), Center zoom in, Center zoom out
func _animate(duration: float):
	tween.remove_all()
	position = _og_pos
	scale = min_zoom

	var rand = randi() % 10  #2 zooms 8 pans
	while _last_anim == rand:
		rand = randi() % 10

	match rand:
		0:
			#zoom in
			tween.interpolate_property(
				self, "scale", min_zoom, max_zoom, duration, Threen.TRANS_LINEAR
			)
		1:
			#zoom out
			tween.interpolate_property(
				self, "scale", max_zoom, min_zoom, duration, Threen.TRANS_LINEAR
			)
		_:
			#pan
			var pan_dir = (randi() % 8) * (PI * 2 / 8.0)  #rad
			var target_offset = _get_max_target_offset(pan_dir)

			var start_pos = _og_pos
			if !pan_from_center:
				start_pos -= target_offset

			tween.interpolate_property(
				self, "position", start_pos, _og_pos + target_offset, duration, Threen.TRANS_LINEAR
			)
	tween.start()
	_last_anim = rand


func _get_max_target_offset(direction) -> Vector2:
	var t_size = texture.get_size() * scale
	assert(t_size >= display_size)
	var diff = t_size - display_size

	var dir_vector = Vector2(cos(direction), sin(direction))

	var target_offset = dir_vector * max(diff.y, diff.x)
	var padding = 5 * scale  #px
	target_offset.y = clamp(target_offset.y, -diff.y + padding.y, diff.y - padding.y) / 2.0
	target_offset.x = clamp(target_offset.x, -diff.x + padding.x, diff.x - padding.x) / 2.0

	return target_offset
