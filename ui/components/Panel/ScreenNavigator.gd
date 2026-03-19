extends Panel

signal panel_shown
signal panel_hidden
signal screen_pushed
signal screen_popped

const HIDE_SCALE = 0.7
const ANIM_DUR_NONE = 0
const ANIM_DUR_DEFAULT = 0.3

const Screen = preload("res://ui/screens/Screen.gd")
const Route = preload("res://ui/components/Panel/Route.gd")
const Modal = preload("res://ui/modals/Modal.gd")

@onready var tween = Threen.new()
@onready var panel = get_parent()

var _anim_dur = ANIM_DUR_DEFAULT
var _screen_stack: Array = []

var _route_defs = RouteDefinitions.new(self)
var routes = [
	Route.new("/picture", _route_defs.picture),
	Route.new("/chat", _route_defs.chat),
	Route.new("/chat/home", _route_defs.chat_home),
	Route.new("/chat/info", _route_defs.chat_info),
	Route.new("/calendar", _route_defs.calendar),
	Route.new("/weather", _route_defs.weather),
	Route.new("fb://feed", _route_defs.fb_feed),
	Route.new("fb://profiles/*", _route_defs.fb_member),
	Route.new("fb://pages/*", _route_defs.fb_member),
	Route.new("fb://groups/*", _route_defs.fb_member),
	Route.new("fb://posts/*", _route_defs.fb_status),
	Route.new("fb://posts/*/comments/*", _route_defs.fb_status),
	Route.new("fb://posts/*/comments/*/replies/*", _route_defs.fb_status),
	Route.new("fb://album", _route_defs.fb_album),
	Route.new("fb://picture", _route_defs.fb_picture),
	Route.new("fb://comment", _route_defs.fb_comment),
	Route.new("email://sequence", _route_defs.email_sequence),
	Route.new("https://>", _route_defs.web_browser),
	Route.new("geddit://posts/*", _route_defs.geddit),
	Route.new("email://inbox", _route_defs.email_inbox),
]


func _enter_tree():
	Story.add_command_handler(_run_command)


func _exit_tree():
	Story.remove_command_handler(_run_command)


func _ready():
	add_child(tween)
	panel.visibility_changed.connect(reset_top_focus)
	Game.config.hide_props_changed.connect(_update_from_game_config)
	_update_from_game_config()


func _update_from_game_config():
	modulate = Color.TRANSPARENT if Game.config.hide_phone else Color.WHITE


func push(screen: Screen):
	var last_top = top()
	if last_top != null:
		Utils.set_process_input_rec(last_top, false)
		_anim_push_out(last_top)

	_screen_stack.push_back(screen)
	add_child(screen)
	_set_bg_color(screen.bg_color)
	_anim_slide(screen, false)

	screen.bg_color_changed.connect(_on_bg_color_changed.bind(screen))
	screen._mount()
	screen._before_show()
	if last_top != null:
		last_top._before_hide()

	if is_panel_shown():
		$SoundSlideRight.play()

	tween.start()
	await tween.tween_completed
	Story.emit("_phone_screen_pushed")
	screen._after_show()
	if last_top != null:
		last_top._after_hide()
		last_top._after_hide()


func push_named(path: String, payload: Dictionary = {}) -> bool:
	var top = top()
	if top != null and top._push_named(path):
		return true

	var routes_inv = routes.duplicate()
	routes_inv.reverse()

	for route in routes_inv:
		var screen = route.get_screen(path, payload)
		if screen is Screen:
			await push(screen)
			screen_pushed.emit()
			return true

	return false


func pop():
	if top() == null:
		await Utils.wait(0)
		return

	var to_pop = _screen_stack.pop_back()
	var to_show = top()
	Utils.set_process_input_rec(to_pop, false)
	to_pop.bg_color_changed.disconnect(_on_bg_color_changed)

	if to_show == null:
		if is_panel_shown():
			hide_panel()
	else:
		_anim_slide(to_pop, true)

		if to_show != null:
			Utils.set_process_input_rec(to_show, true)
			_anim_pull_in(to_show)
			_set_bg_color(to_show.bg_color)
			to_show._before_show()

	if is_panel_shown():
		$SoundSlideLeft.play()

	to_pop._before_hide()
	screen_popped.emit()
	tween.start()
	await tween.tween_all_completed
	Story.emit("_phone_screen_popped")



	if to_show != null:
		to_show._after_show()
	to_pop._after_hide()
	to_pop._unmount()
	to_pop.queue_free()



func top():
	if _screen_stack.size() > 0:
		return _screen_stack[-1]


func reveal_modal(modal: Modal):
	var top = top()
	if top:
		top.reveal_modal(modal)


func dismiss_modal():
	var top = top()
	if top:
		top.dismiss_modal()


func show_panel(duration: float = 0.5):
	if top() == null:
		return

	var from = panel.position
	var to = Vector2.ZERO

	if panel.anchor_right == 1:
		from.x = get_viewport_rect().size.x
		to.x = get_viewport_rect().size.x - panel.size.x

	tween.interpolate_property(
		panel, "position", from, to, duration, Threen.TRANS_CUBIC, Threen.EASE_IN_OUT
	)
	tween.start()
	$SoundSlideRight.play()

	await tween.tween_completed
	panel_shown.emit()
	Story.emit("_phone_shown")
	$Focus.push()


func hide_panel(duration: float = 0.5):
	var from = panel.position
	var to = Vector2(-panel.size.x, 0)

	if panel.anchor_right == 1:
		to.x = get_viewport_rect().size.x

	tween.interpolate_property(
		panel, "position", from, to, duration, Threen.TRANS_CUBIC, Threen.EASE_IN_OUT
	)
	tween.start()
	$SoundSlideLeft.play()

	await tween.tween_completed
	panel_hidden.emit()
	Story.emit("_phone_hidden")
	$Focus.pop()


func set_panel_position(position: String = "left"):
	if position == "left":
		panel.position.x = 0
		panel.anchor_left = 0
		panel.anchor_right = 0
	elif position == "right":
		panel.position.x = get_viewport_rect().size.x
		panel.anchor_left = 1
		panel.anchor_right = 1
	else:
		assert(false)


func is_panel_shown():
	return panel.position.x > -panel.size.x


func reset_top_focus():
	if top() == null:
		return

	if "focus_on_enter" in top() and top().focus_on_enter != null:
		top().focus_on_enter.grab_focus()

func _on_bg_color_changed(screen: Screen):
	if top() == screen:
		_set_bg_color(screen.bg_color)


func _set_bg_color(color: Color):
	var stylebox = get_theme_stylebox("panel")
	tween.interpolate_property(
		stylebox, "bg_color", stylebox.bg_color, color, _anim_dur, Threen.TRANS_LINEAR, Threen.EASE_IN
	)
	tween.start()


func _anim_push_out(screen: Screen):
	_anim_scale(screen, 1, HIDE_SCALE)
	_anim_alpha(screen, 1, 0)
	await tween.tween_completed
	screen.visible = false


func _anim_pull_in(screen: Screen):
	_anim_scale(screen, HIDE_SCALE, 1)
	_anim_alpha(screen, 0, 1)
	screen.visible = true


func _anim_slide(screen: Screen, out: bool):
	var pos_shown = screen.position
	var pos_hidden = pos_shown - Vector2(300, 0)
	var pos = [pos_hidden, pos_shown]
	var a = [0, 1]

	if panel.anchor_right == 1:
		pos[0] *= -1

	if out:
		pos.reverse()
		a.reverse()

	tween.interpolate_property(
		screen, "position", pos[0], pos[1], _anim_dur, Threen.TRANS_QUAD, Threen.EASE_OUT
	)
	_anim_alpha(screen, a[0], a[1])


func _anim_alpha(screen: Screen, from: float, to: float):
	var to_mod = screen.modulate
	var from_mod = to_mod
	to_mod.a = to
	from_mod.a = from
	screen.modulate = from_mod

	tween.interpolate_property(
		screen, "modulate", from_mod, to_mod, _anim_dur, Threen.TRANS_QUAD, Threen.EASE_OUT
	)


func _anim_scale(screen: Screen, from: float, to: float):
	var from_scale = Vector2.ONE * from
	var to_scale = Vector2.ONE * to
	screen.pivot_offset = screen.size / 2

	tween.interpolate_property(
		screen, "scale", from_scale, to_scale, _anim_dur, Threen.TRANS_QUAD, Threen.EASE_OUT
	)


func _clear_screens():
	tween.stop_all()
	_anim_dur = ANIM_DUR_NONE

	while top() != null:
		await pop()

	await Utils.wait(0)
	_anim_dur = ANIM_DUR_DEFAULT


func _run_command(cmd: Command):
	var params = cmd.params

	match cmd.name:
		"show_phone":
			var duration = Utils.array_get(params, 0, 0.5)
			await show_panel(duration)
		"hide_phone":
			var duration = Utils.array_get(params, 0, 0.5)
			await hide_panel(duration)
		"clear_phone":
			await hide_panel()
			await get_tree().process_frame
			await _clear_screens()
		"push_screen", "push_named":
			await push_named(params[0], cmd.tags)
		"pop_screen":
			await pop()
		"set_phone_position":
			set_panel_position(params[0])
		_:
			return Constants.CMD_RETURN_NONE

	return null

### Route defs ###
class RouteDefinitions:
	const Screen = preload("res://ui/screens/Screen.gd")
	const ChatScreen = preload("res://ui/screens/ChatScreen/ChatScreen.tscn")
	const ChatHomeScreen = preload("res://ui/screens/ChatHomeScreen/ChatHomeScreen.tscn")
	const ChatInfoScreen = preload("res://ui/screens/ChatInfoScreen/ChatInfoScreen.tscn")
	const Conversation = preload("res://data/story/Conversation.gd")

	const PictureScreen = preload("res://ui/screens/PictureScreen/PictureScreen.tscn")
	const FbMemberScreen = preload("res://ui/screens/FbMemberScreen/FbMemberScreen.tscn")
	const FbFeedScreen = preload("res://ui/screens/FbFeedScreen/FbFeedScreen.tscn")
	const FbStatusScreen = preload("res://ui/screens/FbStatusScreen/FbStatusScreen.tscn")
	const FbStatus = preload("res://data/fb/FbStatus.gd")
	const FbAlbumScreen = preload("res://ui/screens/FbAlbumScreen/FbAlbumScreen.tscn")
	const FbVideoScreen = preload("res://ui/screens/FbVideoScreen/FbVideoScreen.tscn")
	const FbPictureScreen = preload("res://ui/screens/FbPictureScreen/FbPictureScreen.tscn")
	const FbCommentScreen = preload("res://ui/screens/FbCommentScreen/FbCommentScreen.tscn")

	const EmailScreen = preload("res://ui/screens/EmailScreen/EmailScreen.tscn")
	const InboxScreen = preload("res://ui/screens/InboxScreen/InboxScreen.tscn")

	const WeatherScreen = preload("res://ui/screens/WeatherScreen/WeatherScreen.tscn")

	const WebBrowserScreen = preload("res://ui/screens/Web/WebBrowserScreen/WebBrowserScreen.tscn")
	const GedditScreen = preload("res://ui/screens/GedditScreen/GedditScreen.tscn")

	const CalendarScreen = preload("res://ui/screens/CalendarScreen/CalendarScreen.tscn")

	var navigator

	func _init(navigator):
		self.navigator = navigator

	func _init_screen(screen: Screen, props: Dictionary = {}, meta: Dictionary = {}):
		screen.navigator = navigator
		screen.meta = meta
		for key in props:
			screen[key] = props[key]
		return screen

	func picture(params: Array, payload: Dictionary):
		var screen = PictureScreen.instantiate()
		var hide_back_btn = payload.get("hide_back_btn", false)
		return _init_screen(
			screen,
			{
				"picture": payload.picture,
				"load_delay": payload.get("load_delay", 0.0),
				"hide_back_btn": hide_back_btn
			}
		)

	func chat(params: Array, payload: Dictionary):
		var conversation: Conversation
		var hide_back_btn = payload.get("hide_back_btn", false)

		if payload.has("conversation"):
			conversation = payload.conversation
		elif payload.has("id"):
			var handler = Service.of("ChatHandler")
			if handler:
				conversation = handler.get_conversation_with_id(payload.id)

		if conversation is Conversation:
			var screen = ChatScreen.instantiate()
			return _init_screen(
				screen,
				{"conversation": conversation, "hide_back_btn": hide_back_btn},
				{
					"type": "chat",
					"conversation_id": conversation.id,
				}
			)

	func chat_home(params: Array, payload: Dictionary):
		var screen = ChatHomeScreen.instantiate()
		return _init_screen(
			screen,
			{},
			{
				"type": "chat_home",
			}
		)

	func chat_info(params: Array, payload: Dictionary):
		var screen = ChatInfoScreen.instantiate()
		return _init_screen(
			screen,
			{"conversation": payload.conversation},
			{"type": "chat_info", "conversation_id": payload.conversation.id}
		)

	func weather(params: Array, payload: Dictionary):
		var screen = WeatherScreen.instantiate()
		return _init_screen(screen, {}, payload)

	func fb_feed(params: Array, payload: Dictionary):
		var screen = FbFeedScreen.instantiate()
		var hide_back_btn = payload.get("hide_back_btn", false)
		return _init_screen(
			screen,
			{
				"status_uids": payload.status_uids,
				"hide_back_btn": hide_back_btn
			}

		)

	func fb_member(params: Array, payload: Dictionary):
		var screen = FbMemberScreen.instantiate()
		return _init_screen(screen, {"member": FbUtils.get_member(params[0])})

	func fb_status(params: Array, payload: Dictionary):
		var status_ref = "fb://posts/" + params[1]
		var status_json = Store.get_value(status_ref)
		var status_screen = FbStatusScreen.instantiate()
		var status = FbStatus.new(params[1], status_json)

		if params.size() >= 3:
			var comment_uid = params[2]
			var comment = status.comments.get(comment_uid)
			status_screen.scroll_to_comment_uid = comment_uid

			if params.size() >= 4 and comment:
				var comment_screen = FbCommentScreen.instantiate()
				comment_screen.comment = comment
				comment_screen.scroll_to_reply_uid = params[3]
				return comment_screen

		status_screen.status = status
		return status_screen

	func fb_album(params: Array, payload: Dictionary):
		var screen = FbAlbumScreen.instantiate()
		return _init_screen(
			screen, {"status": payload.status, "scroll_to": payload.get("scroll_to", -1)}
		)

	func fb_video(params: Array, payload: Dictionary):
		var screen = FbVideoScreen.instantiate()
		return _init_screen(screen, {"status": payload.status})

	func fb_picture(params: Array, payload: Dictionary):
		var screen = FbPictureScreen.instantiate()
		return _init_screen(screen, {"atom": payload.atom})

	func fb_comment(params: Array, payload: Dictionary):
		var screen = FbCommentScreen.instantiate()
		return _init_screen(screen, {"comment": payload.comment})

	func email_sequence(params: Array, payload: Dictionary):
		var screen = EmailScreen.instantiate()
		return _init_screen(screen, {"ids": payload.ids})

	func email_inbox(params: Array, payload: Dictionary):
		var screen = InboxScreen.instantiate()
		return _init_screen(screen, {"ids": payload.ids, "mode": payload.get("mode", 0)})

	func web_browser(params: Array, payload: Dictionary):
		var screen = WebBrowserScreen.instantiate()
		return _init_screen(screen, {"initial_url": params[0]})

	func geddit(params: Array, payload: Dictionary):
		var screen = GedditScreen.instantiate()
		return _init_screen(screen, {"post_id": params[1]})

	func calendar(params: Array, payload: Dictionary):
		var screen = CalendarScreen.instantiate()
		var date = Time.get_datetime_dict_from_unix_time(payload["timestamp"])
		return _init_screen(screen, {"date": date})
