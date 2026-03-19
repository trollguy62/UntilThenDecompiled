extends Area3D

@export var short_knot: String
var _skit_container: SkitContainer

@onready var paper_handling_sfx: StudioEventEmitter3D = $PaperHandlingSFX


func _ready():
	assert(paper_handling_sfx)
	input_event.connect(_on_area_input_event)


func _skit_ready(_skit_container: SkitContainer):
	self._skit_container = _skit_container


func _on_area_input_event(camera, event, click_position, click_normal, shape_idx):
	if short_knot == null:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed == true:
			paper_handling_sfx.play()
			await  _start_short()



func _start_short():
	if _skit_container != null and is_instance_valid(_skit_container):
		await _skit_container.start_short(short_knot)
