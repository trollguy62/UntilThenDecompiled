extends Panel

@export_range(0.0, 1.0, 0.01) var progress: float = 0.5:
	set(v):
		progress = clamp(v, 0.0, 1.0)
		caret.position.x = progress * size.x


@onready var caret := $Caret
