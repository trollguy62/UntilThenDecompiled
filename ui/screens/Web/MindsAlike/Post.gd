extends "res://ui/screens/Web/StaticWebPage.gd"

@onready var title := $VBoxContainer/Title
@onready var author_date := $VBoxContainer/AuthorDate
@onready var cover := $VBoxContainer/Cover
@onready var body := $VBoxContainer/Body


func _ready():
	super._ready()
	var id = link.url.split("/")[-1]
	var data = Store.get_value("ma://%s" % id)
	if data == null:
		return

	title.text = data.get("title", "")
	author_date.text = data.get("author", "") + "\n" + data.get("date", "")
	body.text = data.get("body", "")

	var model = WebUtils.get_page_model(link)
	var cover_tex = load(model.display_ref)

	cover.visible = cover_tex != null
	cover.texture = cover_tex
