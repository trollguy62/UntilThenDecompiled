extends Node

@onready var sprite = $"../Sprite"
@onready var state: StateContainer = get_node_or_null("../State")

@export var enabled: bool = true
@export var fallback_idle_talk_anim: String
@export var standalone_anims: Array[String] = []
@export var idle_talk_anims: Array[String] = []
@export var state_container_path: NodePath
# TODO: Only for backwards compatibility, eliminate upon migration to reversed naming
@export var reverse_idle_talk := false


func _ready():
	if state == null:
		state = get_node(state_container_path)
	assert(state != null)


func _process(_delta):
	if enabled:
		sprite.animation = get_animation()


func get_animation() -> String:
	var flags = state.flags

	for anim in standalone_anims:
		if flags.has(anim):
			return anim

	var talking = flags.has("$talk")
	var talk_or_idle = "talk" if talking else "idle"
	var fmt = [talk_or_idle, fallback_idle_talk_anim]

	for anim in idle_talk_anims:
		if flags.has(anim):
			fmt[1] = anim
			break

	if reverse_idle_talk:
		fmt.reverse()

	return "%s_%s" % fmt
