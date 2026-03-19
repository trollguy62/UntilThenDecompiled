extends HBoxContainer

@export var url: String

@onready var thumbnail = $Thumbnail
@onready var title = $Title


func _ready():
	thumbnail.pressed.connect(_open_url)
	title.pressed.connect(_open_url)
	thumbnail.focus_entered.connect(_on_thumbnail_focus_entered)
	thumbnail.focus_exited.connect(_on_thumbnail_focus_exited)

	var model = WebUtils.get_page_model(url)
	if model:
		title.text = model.title

		var thumbnail_tex = load(model.display_ref)
		if thumbnail_tex == null:
			thumbnail.texture = preload("res://assets/ui/hint_white.png")
			thumbnail.modulate = Color.GRAY
		else:
			thumbnail.texture = thumbnail_tex
			thumbnail.modulate = Color.WHITE


func _open_url():
	var navigator = Service.of(Service.NAVIGATOR)
	if navigator:
		navigator.push_named(url)

func _on_thumbnail_focus_entered():
	modulate = Color.GRAY

func _on_thumbnail_focus_exited():
	modulate = Color.WHITE
