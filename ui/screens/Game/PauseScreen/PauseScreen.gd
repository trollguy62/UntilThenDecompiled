extends CanvasLayer

signal paused_changed(paused)

@onready var ui = $UI
@onready var sc_bg = $UI/ScreenshotBG
@onready var page_container = $UI/PageContainer

var _pause_page = preload("res://ui/components/Game/PausePage/PausePage.tscn").instantiate()

func _ready():
	visible = false
	_pause_page.resume_pressed.connect(unpause)
	page_container.push(_pause_page)
	get_window().focus_exited.connect(_on_window_focus_exited)

func _process(_delta):
	ui.process_mode = Node.PROCESS_MODE_WHEN_PAUSED if can_show() else \
			Node.PROCESS_MODE_INHERIT

func __toggle_paused() :
	if can_show():
		pause()
	elif ui.visible:
		unpause()

func can_show():
	var root = Utils.get_root_scene()
	return root is Scene and root.pausable

func pause():
	if Game.paused:
		return
	Game.paused = true
	_take_screenshot()
	paused_changed.emit(true)
	get_viewport().disable_3d = true
	page_container.reenter()
	visible = true

func unpause():
	if not Game.paused:
		return
	if page_container.is_busy():
		return
	Game.paused = false
	paused_changed.emit(false)
	sc_bg.texture = null
	get_viewport().disable_3d = false
	visible = false

func _take_screenshot():
	var img = get_viewport().get_texture().get_image()
	sc_bg.texture = ImageTexture.create_from_image(img)

func _on_window_focus_exited():
	if can_show() and not Utils.is_internal_debug():
		pause()

func _input(ev):
	if ev.is_action_pressed("pause"):
		if page_container.is_busy() or not can_show():
			return
		if page_container.page_count > 1:
			page_container.pop()
			return
		if Game.paused:
			unpause()
		else:
			pause()
