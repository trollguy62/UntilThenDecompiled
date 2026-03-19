extends HBoxContainer

@onready var exit_btn = $ExitBtn

func _ready():
	exit_btn.visibility_changed.connect(_on_exit_btn_visibility_changed)

func _on_exit_btn_visibility_changed():
	visible = exit_btn.visible
