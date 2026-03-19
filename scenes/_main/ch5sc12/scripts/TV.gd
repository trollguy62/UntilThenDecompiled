extends MeshInstance3D

const TV_SURFACE_IDX = 1
const PS_ASPECT_RATIO = 1.3333333
const CreditsViewport = preload("res://scenes/_main/ch5sc12/CreditsViewport.gd")

@export var racing_minigame_viewport: ViewportTexture
@export var credits_viewport_path: NodePath
@onready var tv_surface: ShaderMaterial = get_surface_override_material(TV_SURFACE_IDX)

var credits_viewport: CreditsViewport

func _ready():
	credits_viewport = get_node_or_null(credits_viewport_path) as CreditsViewport
	assert(credits_viewport != null)
	tv_surface.set_shader_parameter("input", racing_minigame_viewport)
	tv_surface.set_shader_parameter("aspect_ratio", PS_ASPECT_RATIO)
	credits_viewport.visibility_changed.connect(_on_credits_visibility_changed)

func _on_credits_visibility_changed(visible):
	if visible:
		tv_surface.set_shader_parameter("input", credits_viewport.get_texture())
		tv_surface.set_shader_parameter("aspect_ratio", 1.0)
	else:
		tv_surface.set_shader_parameter("input", racing_minigame_viewport)
		tv_surface.set_shader_parameter("aspect_ratio", PS_ASPECT_RATIO)
