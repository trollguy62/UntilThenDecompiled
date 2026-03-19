@tool
extends HBoxContainer

@export var flip_h = false:
	set(v):
		flip_h = v
		if flip_h:
			$Icon.move_to_front()
		else:
			$Name.move_to_front()


@export var icon: Texture:
	set(v):
		icon = v
		$Icon.texture = icon

@export var item_name: String = "item":
	set(v):
		item_name = v
		$Name.text = name

func _ready():
	$Icon.texture = icon
	$Name.text = name
