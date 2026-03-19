extends "res://ui/screens/Web/StaticWebPage.gd"

const ArticleComponent = preload("ArticleComponent.tscn")

const ID_LEN = 4

@onready var title = $Margin/VBox/Title
@onready var author = $Margin/VBox/Meta/Author
@onready var time = $Margin/VBox/Meta/Time
@onready var date = $Margin/VBox/Meta/Date
@onready var thumbnail_container = $Margin/VBox/ThumbnailContainer
@onready var thumbnail = $Margin/VBox/ThumbnailContainer/Thumbnail
@onready var body = $Margin/VBox/BodyContainer/Body
@onready var related_list = $Margin/VBox/Related


func _ready():
	super._ready()
	var id = link.url.substr(link.url.length() - ID_LEN, ID_LEN)
	var data = Store.get_value("tlt://%s" % id)
	if data == null:
		return

	author.text = data.get("author", "Juan Dela Cruz")
	time.text = data.get("time", "12:00 AM")
	date.text = data.get("date", "January 1, 2014")
	body.text = data.get("body", "Body here.")

	var model = WebUtils.get_page_model(link)
	var thumbnail_tex = load(model.display_ref)

	title.text = model.title
	thumbnail_container.visible = thumbnail_tex != null
	thumbnail.texture = thumbnail_tex

	var related = data.get("related", [])
	related_list.visible = not related.is_empty()
	for url in related:
		var story = ArticleComponent.instantiate()
		story.url = url
		related_list.add_child(story)
