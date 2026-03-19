extends PanelContainer

const Character = preload("res://data/Character.gd")

var character: Character

@onready var picture = $MarginContainer/Character/Picture
@onready var name_label = $MarginContainer/Character/Name

#FIXME: hack, prevents double-tapping
var _disabled = false

func _ready():
	if character != null:
		picture.texture = character.profile_picture
		name_label.text = character.full_name

		var button = $Button
		focus_entered.connect(button.grab_focus)
		button.pressed.connect(_on_pressed)


func _on_pressed():
	if _disabled:
		return
	_disabled = true
	var navigator = Service.of(Service.NAVIGATOR)
	navigator.push_named("fb://profiles/" + character.fb_profile_uid)

	get_tree().create_timer(1).timeout.connect(func(): _disabled = false)
