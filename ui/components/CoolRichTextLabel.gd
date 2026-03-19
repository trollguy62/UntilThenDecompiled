extends RichTextLabel

const URL_CAPTURE_REGEX = "\\[url=(.*)\\](.*)\\[\\/url\\]"
const HYPERLINK_COLOR = "#0000EE"
const VISITED_COLOR = "#551A8B"

signal text_changed

@export var open_links = true
@export var max_lines_visible: int = -1:
	set(value):
		max_lines_visible = value
		if _is_ready:
			pass
			# PORT: Might be the cause of jittering?
			queue_redraw()

var _is_ready = false
var _line_height = 0
var _links: Dictionary = {} #text: url
var _old_text: String = ""
var _hyperlink: String = "" #bbcode String segment
var _target_link: String = ""

func _ready():
	_is_ready = true
	meta_clicked.connect(_open_link)
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)
	var font = get_theme_font("normal_font")
	var font_height = font.get_height()
	var line_sep = get_theme_constant("line_separation")
	_line_height = font_height + line_sep

	await get_tree().process_frame
	queue_redraw()

func _process(delta):
	#only check if open_links is a thing
	if open_links and _old_text != text :
		_old_text = text
		text_changed.emit()
		_on_text_changed()

func _try_get_links():
	var regex = RegEx.new()
	regex.compile(URL_CAPTURE_REGEX)
	var results = regex.search_all(text)
	#0 search str
	#1 link
	#2 hyperlink text

	var link_data = {}
	for result in results:
		link_data[result.strings[2]] = result.strings[1]
	return link_data

func _draw():
	if text.is_empty():
		_set_height(0)
	else:
		var lines_height = max_lines_visible * _line_height
		var max_height = min(get_content_height(), lines_height)
		_set_height(max_height)

	fit_content = max_lines_visible < 0

func is_completely_visible():
	return size.y == get_content_height()

func _on_text_changed():
	#naive check for url, used for the controller
	if text.contains("url"):
		_links = _try_get_links()
		pass

	if open_links and _links.size() > 0:
		focus_mode = Control.FOCUS_ALL

func _open_link(link: String):
	if open_links:
		var navigator = Service.of(Service.NAVIGATOR)
		if navigator:
			navigator.push_named(link)

func _set_height(h: int):
	custom_minimum_size.y = h
	size.y = h

func _on_focus_entered():
	if _links.is_empty():
		return
	var link_text: String = _links.keys().front()
	_hyperlink = _hyperlinkify(link_text, HYPERLINK_COLOR)
	_target_link = _links[link_text] #url

	text = text.replace(link_text, _hyperlink)

func _hyperlinkify(text: String, color: String) -> String:
	var template_text = "[u][color={color}]{text}[/color][/u]"
	template_text = template_text.format({"color": color, "text": text})
	return template_text

func _remove_bbcode_tags(text):
	var regex = RegEx.new()
	regex.compile("\\[.*?\\]")
	var text_without_tags = regex.sub(text, "", true)
	return text_without_tags

func _on_focus_exited():
	if _links.is_empty():
		return
	var link_text: String = _links.keys().front()
	text = text.replace(_hyperlink, _remove_bbcode_tags(_hyperlink))
	_hyperlink = ""
	_target_link = ""

func _gui_input(event):
	if event.is_action_pressed("c_interact") and open_links:
		_open_link(_target_link)
