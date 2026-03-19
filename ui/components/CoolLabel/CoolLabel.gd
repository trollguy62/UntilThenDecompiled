extends Label

signal pressed

@onready var bg: Panel = $TextBackground

func _ready():
	draw.connect(_on_draw)
	_on_draw()
	focus_entered.connect(bg.call_deferred.bind("grab_focus"))
	bg.pressed.connect(func(): pressed.emit())


func _on_draw():
	var font = get_theme_font("font")
	var ln_count = get_line_count()
	var t = text.to_upper() if uppercase else text

	var sb = get_theme_stylebox("normal")
	var padding_top = sb.content_margin_top
	var padding_bottom = sb.content_margin_bottom
	var padding_left = sb.content_margin_left
	var padding_right = sb.content_margin_right

	var bg_size = font.get_string_size(t)
	var bg_pos = Vector2()

	if ln_count > 1:
		bg_size.x = size.x
	bg_size.y = (get_line_height() + get_theme_constant("line_spacing")) * get_line_count()

	bg_size.x += padding_left + padding_right
	bg_size.y += padding_top + padding_bottom
	bg_size.x = clamp(bg_size.x, 0, size.x)
	bg_size.y = clamp(bg_size.y, 0, size.y)

	if horizontal_alignment == HORIZONTAL_ALIGNMENT_RIGHT:
		bg_pos.x =  size.x - bg_size.x
	elif horizontal_alignment == HORIZONTAL_ALIGNMENT_CENTER:
		bg_pos.x = (size.x - bg_size.x) / 2

	bg.position = bg_pos
	bg.size = bg_size


func set_bg_style(style: StyleBox):
	bg.set("theme_override_styles/panel", style)
