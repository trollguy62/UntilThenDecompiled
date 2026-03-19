extends Node

const MAT_PARAM_WET = "overall_wet"

const RainControllable = preload("RainControllable.gd")

@export_range(0.0, 1.0) var intensity = 0.0:
	set = _set_intensity,
	get = _get_intensity

@onready var tween = Threen.new()

var _is_ready := false
var _controllables := []


func _enter_tree():
	Story.add_command_handler(_run_command)


func _exit_tree():
	Story.remove_command_handler(_run_command)


func _ready():
	add_child(tween)

	var tree = get_tree()
	Utils.traverse_descendants(tree.root, _cache_controllable)
	tree.node_added.connect(_cache_controllable)

	_is_ready = true
	self.intensity = intensity


func _cache_controllable(node: Node):
	if node is RainControllable:
		if not node in _controllables:
			_controllables.append(node)


func _set_intensity(value):
	intensity = value
	if not _is_ready:
		return

	RenderingServer.global_shader_parameter_set("rain_level", intensity)

	for controllable in _controllables:
		if is_instance_valid(controllable):
			controllable.intensity = intensity


func _get_intensity():
	return intensity


func _run_command(cmd: Command):
	if cmd.name == "set_rain_intensity":
		var intensity = float(cmd.params[0])
		var duration = float(Utils.array_get(cmd.params, 1, 0))

		if duration < Constants.EPSILON:
			self.intensity = intensity
		else:
			tween.interpolate_property(self, "intensity", self.intensity, intensity, duration)
			tween.start()

		return null
	return Constants.CMD_RETURN_NONE
