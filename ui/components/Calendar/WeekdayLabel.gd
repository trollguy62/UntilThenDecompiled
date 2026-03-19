extends Button

const TEXT_PADDING = 4
const DEFAULT_FONT_SIZE = 28

@export var base_color: Color = Color.WHITE_SMOKE
@export var selected_color: Color = Color("#f26b00")
@export var max_width: int = 40:
	set(v):
		max_width = v
		
@onready var label = $Label

@onready var _last_language = TranslationServer.get_locale()

func _ready():
	resized.connect(_on_resized)
	label.custom_minimum_size = Vector2()

func _process(delta):
	#hack
	if TranslationServer.get_locale() != _last_language:
		_last_language = TranslationServer.get_locale()
		_on_resized()

func _toggled(button_pressed):
	self.modulate = selected_color if button_pressed else base_color

func _on_resized():
	label.label_settings.font_size = DEFAULT_FONT_SIZE
	while label.size.x > size.x - TEXT_PADDING:
		label.label_settings.font_size -= 1
		label.size = custom_minimum_size
		label.anchors_preset = PRESET_CENTER
