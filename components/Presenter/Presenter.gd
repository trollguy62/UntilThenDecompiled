extends Control

signal is_shown
signal is_hidden

const DEFAULT_DURATION := 0.4

@onready var anim_player = $AnimationPlayer
@onready var focus = $Focus
@onready var texture_rect_container = $Control/TextureRectContainer
@onready var texture_rect = $Control/TextureRectContainer/TextureRect
@onready var scene_container = $Control/SceneContainer
@onready var rich_text_label_container = $Control/RichTextLabelContainer
@onready var rich_text_label = $Control/RichTextLabelContainer/PanelContainer/ScrollContainer/RichTextLabel

var _can_dismiss := false

var dismiss_duration := -1.0


func _ready():
	mouse_filter = MOUSE_FILTER_IGNORE
	modulate = Color.TRANSPARENT

	is_shown.connect(Story.emit.bind("_presenter_shown"))
	is_hidden.connect(Story.emit.bind("_presenter_hidden"))


func _input(event):
	if event.is_action_pressed("interact"):
		if _can_dismiss and focus.active:
			unpresent()


func _process(delta):
	material.set_shader_parameter("modulate", modulate)


func present(
	obj, dismissible: bool = true, duration: float = DEFAULT_DURATION, scale: Vector2 = Vector2.ZERO
):
	_can_dismiss = false
	texture_rect_container.visible = false
	scene_container.visible = false
	rich_text_label_container.visible = false
	mouse_filter = MOUSE_FILTER_STOP

	focus.push()

	for child in scene_container.get_children():
		child.queue_free()

	if obj is Texture:
		var texture = obj as Texture
		texture_rect_container.visible = true
		texture_rect.texture = texture
		texture_rect.pivot_offset = texture.get_size() / 2.0

		await get_tree().process_frame

		if scale == Vector2.ZERO:
			scale = Vector2.ONE * 4.0

		texture_rect.custom_minimum_size = texture.get_size() * scale
	elif obj is String:
		rich_text_label_container.visible = true
		rich_text_label.text = obj
	elif obj is PackedScene:
		var inst = (obj as PackedScene).instantiate()
		scene_container.visible = true
		scene_container.add_child(inst)

		if scale == Vector2.ZERO:
			scale = Vector2.ONE * 1.0
		scene_container.scale = scale

	anim_player.play("show", -1, 1.0 / duration)

	await anim_player.animation_finished
	_can_dismiss = dismissible
	is_shown.emit()


func unpresent(duration: float = DEFAULT_DURATION):
	if dismiss_duration >= 0:
		duration = dismiss_duration
		dismiss_duration = -1

	_can_dismiss = false
	anim_player.play("hide", -1, 1.0 / duration)

	await anim_player.animation_finished
	mouse_filter = MOUSE_FILTER_IGNORE
	focus.pop()
	is_hidden.emit()


### Command handler ###
var _command_handler = _run_command


func _enter_tree():
	Story.add_command_handler(_command_handler)


func _exit_tree():
	Story.remove_command_handler(_command_handler)


func _run_command(cmd: Command):
	var params = cmd.params
	var flags = cmd.flags
	var tags = cmd.tags

	match cmd.name:
		"present":
			var path = params[0] as String
			var obj

			if path.begins_with("res://"):
				obj = load(params[0])
			# TODO: Not the best condition to test for "db://..."
			elif path.find("://") > 0:
				obj = Store.get_value(path)


			if not (obj is PackedScene or obj is Texture or obj is String):
				return Constants.CMD_RETURN_NONE

			var duration = tags.get("duration", DEFAULT_DURATION)
			var dismissible = tags.get("dismissible", true)
			var scale = Vector2.ZERO

			if tags.has("scale"):
				scale = Vector2.ONE * tags["scale"]

			if tags.has("dismiss_duration"):
				dismiss_duration = tags["dismiss_duration"]
			elif tags.get("equal_dismiss_duration", false):
				dismiss_duration = duration

			await present(obj, dismissible, duration, scale)
		"unpresent":
			var duration = tags.get("duration", DEFAULT_DURATION)
			await unpresent(duration)
		_:
			return Constants.CMD_RETURN_NONE

	return null
