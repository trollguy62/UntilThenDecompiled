extends "res://ui/screens/Screen.gd"

const WebPage = preload("res://ui/screens/Web/WebPage.gd")
const WebOfflinePage = preload("res://ui/screens/Web/WebOfflinePage/WebOfflinePage.tscn")
const WebRefusedPage = preload("res://ui/screens/Web/WebRefusedPage/WebRefusedPage.tscn")

@onready var menu = $Menu
@onready var url_hbox = $Menu/Margin/HBox/LinkBox/HBox/URLContainer/URL
@onready var url_protocol = $Menu/Margin/HBox/LinkBox/HBox/URLContainer/URL/Protocol
@onready var url_link = $Menu/Margin/HBox/LinkBox/HBox/URLContainer/URL/Link
@onready var progress_bar = $Menu/Margin/HBox/LinkBox/ProgressBar
@onready var back_btn = $Menu/Margin/HBox/MarginContainer/BackButton
@onready var ctrl_btn = $Menu/Margin/HBox/LinkBox/HBox/ButtonContainer/CtrlButton

@onready var tween = Threen.new()
@onready var scroll = $Body/Scroll
@onready var page_container = $Body/Scroll/Main/PageContainer

@export var initial_url = ""

var scroll_pivot := 0
var menu_shown := true

var history := []  # String[]
var visited := {}  # TODO save state, probably in Store config???
var page: WebPage


func _ready():
	super._ready()
	
	add_child(tween)
	back_btn.pressed.connect(back)
	ctrl_btn.pressed.connect(_on_ctrl_btn_pressed)
	scroll.scroll_started.connect(_on_scroll_started)

	if initial_url != "":
		goto(initial_url)


func goto(url: String) -> bool:
	var link = WebUtils.make_web_link(url)
	if link == null:
		return false

	if page:
		page.cancel()
		page_container.remove_child(page)
		page.queue_free()

	scroll.scroll_to_start()
	scroll.size.y = 0

	var new_page = WebUtils.get_page(link)
	var speed_mult = 8.0 if visited.has(url) else 1.6

	if history.is_empty() or history.back() != url:
		history.append(url)

	if Game.has_internet:
		if new_page:
			page = new_page
			page.loaded.connect(_on_url_loaded.bind(url))
		else:
			page = WebRefusedPage.instantiate()
			page.link = link
	else:
		page = WebOfflinePage.instantiate()
		page.link = link

	page_container.add_child(page)
	page.load(speed_mult)
	return true


func _push_named(url: String):
	return goto(url)


func back():
	history.pop_back()
	if history.is_empty():
		if not back_btn.disabled:
			navigator.pop()
	else:
		goto(history.back())


func _on_url_loaded(url: String):
	visited[url] = true


func _process(delta):
	var ds = scroll.scroll_vertical - scroll_pivot
	_set_menu_visibility(ds < 60)

	progress_bar.visible = page != null
	url_hbox.visible = page != null
	ctrl_btn.visible = page != null

	if page != null:
		ctrl_btn.button_pressed = page.is_loading
		url_protocol.text = page.link.protocol
		url_link.text = page.link.url_without_protocol()

		progress_bar.scale.x = lerp(progress_bar.scale.x, page.progress, 0.2)
		progress_bar.modulate = lerp(
			progress_bar.modulate, Color.WHITE if page.is_loading else Color.TRANSPARENT, 0.2
		)


func _on_scroll_started():
	scroll_pivot = scroll.scroll_vertical + menu.position.y


func _on_ctrl_btn_pressed():
	if page is WebPage:
		if page.is_loading:
			page.cancel()
		else:
			goto(page.link.url)


func _set_menu_visibility(show: bool):
	if menu_shown == show:
		return

	menu_shown = show
	var p0 = menu.position
	var p1 = p0
	p1.y = 0 if show else -menu.size.y - 8

	tween.interpolate_property(
		menu, "position", p0, p1, 0.2, Threen.TRANS_QUAD, Threen.EASE_IN_OUT
	)
	tween.start()

func _unhandled_input(event):
	if event.is_action_pressed("c_cancel") and back_btn.is_visible_in_tree():
		back()
