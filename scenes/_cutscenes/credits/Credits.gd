extends "res://scenes/_cutscenes/CutScene.gd"

const CREDITS_FILEPATH = "res://assets/databases/credits.json"
const RECOMMENDED_MAX_MEMBER_COUNT = 27

const RTL = preload("res://scenes/_cutscenes/credits/RTL.tscn")
const LongPage = preload("res://scenes/_cutscenes/credits/LongPage.tscn")
const HeaderLabel = preload("res://scenes/_cutscenes/credits/HeaderLabel.tscn")
const MemberLabel = preload("res://scenes/_cutscenes/credits/MemberLabel.tscn")

signal credits_finished

@onready var music = $Music
@onready var main = $Main

@export var start_delay := 3.0
@export var end_delay := 3.0
@export var credits: Array[Control] = []
@export var go_to_main_menu_on_end: bool = true
@export var run_on_ready: bool = true


func _ready():
	super._ready()
	main.modulate = Color.TRANSPARENT

	var raw: Dictionary = Utils.read_json_file(CREDITS_FILEPATH)
	credits = creditsify(raw)

	if run_on_ready:
		_roll_credits()


func creditsify(raw: Dictionary):
	var ret: Array[Control]
	for page_name in raw.keys():
		var raw_page: Dictionary = raw[page_name]
		var parsed_page: Control
		if raw_page.get("use_long_format", false):
			var use_blocks = raw_page.get("use_blocks", false)
			parsed_page = _parse_long_format(raw_page, use_blocks)
		else:
			var parsed_section: String
			for section in raw_page["sections"]:
				parsed_section += _parse_section(section)
			parsed_page = _generate_block(parsed_section)

		ret.append(parsed_page)
	return ret


func _generate_block(bb_text: String, min_width = 0) -> RichTextLabel:
	var rtl = RTL.instantiate()
	#if min_width > 0:
		#rtl.set("custom_minimum_size:x", min_width)
	rtl.custom_min_width = min_width
	rtl.text = "[center]%s[/center]" % bb_text.strip_edges()
	return rtl


func _parse_long_format(raw: Dictionary, use_blocks = false):
	var lp = LongPage.instantiate()
	var content: Array[Control] = []
	if use_blocks:
		var internal_resolution_x = ProjectSettings.get_setting_with_override("display/window/size/viewport_width")
		var max_block_columns = raw.get("max_block_columns", 3)
		var block_width = (internal_resolution_x - 160) / max_block_columns

		for section in raw["sections"]:
			var parsed_section = _parse_section(section)
			var block = _generate_block(parsed_section, block_width)
			content.append(block)

	else:
		if "header" in raw:
			lp.header_text = raw["header"]
		for section in raw["sections"]:
			if "title" in section:
				var header = HeaderLabel.instantiate()
				header.text = section["title"]

			if "members" in section:
				var members: Array = section["members"]
				for member in members:
					var label = MemberLabel.instantiate()
					label.text = member
					content.append(label)

				if members.size() > RECOMMENDED_MAX_MEMBER_COUNT:
					printerr("Member count ({0}) for page is over recommended ({1})! Consider using a new page instead".format([members.size() , RECOMMENDED_MAX_MEMBER_COUNT]))

	lp.content = content
	return lp


func _parse_section(section: Dictionary) -> String:
	var parsed: String = ""
	if "title" in section:
		var title = tr(section["title"])
		parsed += title
		parsed += "\n"

	if "members" in section:
		var members: Array = section["members"]

		var text: String = ""
		for member in members:
			text += "[b]{0}[/b]".format([tr(member)])
			text += "\n"

		parsed += text
		parsed += "\n"

	if "image" in section:
		var image = section["image"]
		var image_str
		var base_string = "[img={size}]{path}[/img]"
		var path: String = image["path"]
		var size: String = image["size"] if "size" in image else ""
		if size.is_empty():
			base_string = "[img]{path}[/img]"

		image_str = base_string.format({"size": size, "path": path})
		parsed += image_str

	return parsed

func roll():
	_roll_credits()

func _roll_credits():
	await Utils.wait(Game.get_scene_param("override_start_delay", start_delay))
	music.play()

	for page in credits:
		main.add_child(page)
		await _fade(true)
		await Utils.wait(3)
		await _fade(false)
		await Utils.wait(0.5)
		page.queue_free()

	await Utils.wait(end_delay)
	_next()


func _fade(fade_in: bool):
	var to = main.modulate
	to.a = 1 if fade_in else 0

	var new_tween = get_tree().create_tween()
	new_tween.tween_property(main, "modulate", to, 1)
	await new_tween.finished


func _next():
	credits_finished.emit()
	if go_to_main_menu_on_end:
		Game.go_to_main_menu()
