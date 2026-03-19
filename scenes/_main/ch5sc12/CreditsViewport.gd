extends SubViewport

signal visibility_changed(state)

@onready var credits = $Credits

func _ready():
	credits.visibility_changed.connect(_on_credits_visibility_changed)


func _on_credits_visibility_changed():
	visibility_changed.emit(credits.visible)
