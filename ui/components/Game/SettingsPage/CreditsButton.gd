extends TextureButton

@onready var bg = $PanelContainer


func _ready():
	bg.visible = false
	
	focus_entered.connect(_on_focus_changed.bind(true))
	focus_exited.connect(_on_focus_changed.bind(false))
	
	mouse_entered.connect(_on_focus_changed.bind(true))
	mouse_exited.connect(_on_focus_changed.bind(false))


func _on_focus_changed(entered: bool):
	bg.visible = entered
