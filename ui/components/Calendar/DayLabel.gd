extends Button

@export var selected = false:
	set(v):
		$Bg.visible = v
		selected = v

func _ready():
	selected = selected

func select():
	selected = true
