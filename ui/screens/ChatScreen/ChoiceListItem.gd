extends HBoxContainer

signal pressed

const CHOICE_ACTION_PREFIX = "choice_"

@export var text_color: Color = Color.WHITE
@export var text_bg_color: Color = Color.WHITE

@onready var key_hint_texture = $KeyHintContainer/KeyHint/ControllerTextureRect
@onready var button = $FlatLabelButton

@onready var action: String = Constants.CHOICE_KEYS[idx]

var idx: int = 0
var text: String = ""


func _ready():
	key_hint_texture.path = "choice_" + str(idx + 1)
	button.text = text
	button.text_color = text_color
	button.bg_color = text_bg_color
	button.pressed.connect(func(): pressed.emit())


func _process(delta):
	if is_visible_in_tree():
		action = Constants.CHOICE_KEYS[idx]

func _unhandled_input(event):
	if is_visible_in_tree():
		if event.is_action_pressed(action):
			pressed.emit()
