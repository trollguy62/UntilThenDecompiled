extends Control

const WebPageModel = preload("res://data/web/WebPageModel.gd")

@onready var display = $Panel/VBox/Display
@onready var title_label = $Panel/VBox/Meta/HBox/Info/Title
@onready var description_label = $Panel/VBox/Meta/HBox/Info/Description
@onready var domain_label = $Panel/VBox/Meta/HBox/Info/Domain
@onready var info_container = $Panel/VBox/Meta/HBox/Info
@onready var cta_btn = $Panel/VBox/Meta/HBox/CTA

var page: WebPageModel:
	set = _set_page,
	get = _get_page
var cta: String:
	set = _set_cta,
	get = _get_cta


func _ready():
	self.page = page
	self.cta = cta

	info_container.pressed.connect(_open_link)
	cta_btn.pressed.connect(_open_link)


func _set_page(value):
	page = value
	if display and page:
		display.load_delay = randf_range(0.4, 1.0)
		display.picture = page.display_ref
		display.alt_route = page.link.url
		domain_label.text = page.link.domain
		title_label.text = page.title
		description_label.visible = not page.description.is_empty()
		description_label.text = page.description


func _get_page():
	return page


func _set_cta(value):
	cta = value
	if cta_btn:
		cta_btn.text = cta
		cta_btn.visible = not cta.is_empty()


func _get_cta():
	return cta


func _open_link():
	var navigator = Service.of(Service.NAVIGATOR)
	if navigator and page:
		navigator.push_named(page.link.url)
