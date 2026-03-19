extends Node

const FADE_DURATION = 0.3

#warning-ignore:unused_signal
signal advanced

const AccurateDelaySource = preload("res://components/AccurateDelaySource.gd")
const State = preload("res://data/State.gd")

const DialogueText = preload("res://data/DialogueText.gd")
const SubstoryContext = preload("res://data/story/SubstoryContext.gd")

@onready var panel = $CanvasLayer/Panel
@onready var label = $CanvasLayer/Panel/Label
@onready var hint_next = $CanvasLayer/Panel/HintNextContainer/HintNext
@onready var focus = $Focus

@onready var hover_sound = $SoundHover
@onready var text_sound = $SoundText

var _state: TbState
var _dlg_text: DialogueText
var _context: SubstoryContext


func _ready():
	_set_state(HiddenState.new(self))


func _input(ev):
	var next_state = _state._input(ev)
	if next_state:
		_set_state(next_state)


func _process(delta):
	var next_state = _state._process(delta)
	if next_state:
		_set_state(next_state)


func _set_state(value: TbState):
	if _state:
		_state.exit()
	_state = value
	_state.enter()


func show(text: String, duration: float = 0, context: SubstoryContext = null):
	if _dlg_text != null:
		return await get_tree().process_frame

	if context == null:
		_context = Story.context
	else:
		_context = context

	_dlg_text = DialogueText.new(text, duration)
	await self.advanced


### Command handler ###
var _command_handler = _run_command


func _enter_tree():
	Story.add_command_handler(_command_handler)


func _exit_tree():
	Story.remove_command_handler(_command_handler)


func _run_command(cmd: Command):
	if cmd.name == "thought":
		show(cmd.params[0])
		await self.advanced
		return null
	else:
		return Constants.CMD_RETURN_NONE


### States ###
class TbState:
	extends State
	var tb

	func _init(tb):
		self.tb = tb


class HiddenState:
	extends TbState

	func _init(tb):
		super(tb)

	func enter():
		tb.panel.clickable = false
		tb.focus.pop()
		tb.panel.modulate = Color.TRANSPARENT
		tb.hint_next.hide(0)

	func _process(_delta):
		if tb._dlg_text != null:
			tb.focus.push()
			var next_state = ActiveState.new(tb, tb._dlg_text)
			tb._dlg_text = null
			return FadeState.new(tb, true, next_state)


class FadeState:
	extends TbState
	var into: bool
	var next_state: TbState
	var next := false

	func _init(tb, into, next_state):
		super(tb)
		self.into = into
		self.next_state = next_state

		if into:
			tb.hover_sound.play()

	func enter():
		tb.panel.clickable = true

		var dur = FADE_DURATION
		var color = [Color.TRANSPARENT, Color.WHITE]
		var scale = [Vector2.ONE * 0.75, Vector2.ONE]
		tb.panel.pivot_offset = tb.panel.size / 2

		if not into:
			color.reverse()
			scale.reverse()
		else:
			tb.label.text = "" # clear() does not work as of writing

		tb.panel.modulate = color[0]
		tb.panel.scale = scale[0]

		var tween = tb.create_tween()
		tween.set_parallel()
		tween.tween_property(tb.panel, "modulate", color[1], dur)
		tween.tween_property(tb.panel, "scale", scale[1], dur) \
			.set_trans(Tween.TRANS_CUBIC) \
			.set_ease(Threen.EASE_OUT if into else Threen.EASE_IN)

		await tween.finished
		next = true

	func _process(_delta):
		if next:
			return next_state


class ActiveState:
	extends TbState

	var dlg_text
	var skip_reveal := false
	var reveal_done := false
	var next_state: TbState

	func _init(tb, dlg_text):
		super(tb)
		self.dlg_text = dlg_text

	func enter():
		tb.panel.clickable = true

		tb.panel.pressed.connect(_on_press_advance)
		tb.hint_next.hide()

		if not tb.label.text.is_empty():
			tb.label.modulate = Color.WHITE

			var tween = tb.create_tween()
			tween.tween_property(tb.label, "modulate", Color.TRANSPARENT, 0.15)
			await tween.finished

			await Utils.wait(0.1)
			tb.label.modulate = Color.WHITE

		# TODO: Try to avoid orphans like SpeechBubble does
		tb.label.text = "[center]%s[/center]" % dlg_text.final_text
		tb.label.visible_characters = 0
		_reveal_text()

	func exit():
		tb.panel.pressed.disconnect(_on_press_advance)

	func _on_press_advance():
		if dlg_text.is_timed() or not tb.focus.active:
			return

		if reveal_done:
			await Utils.wait(0)
			_set_next_state()
		else:
			skip_reveal = true

	func _process(delta):
		var debug_next = Utils.is_debug() and Input.is_key_pressed(KEY_P) \
				and not Game.record_replay_is_active()

		if Input.is_action_just_pressed("ui_accept") \
			or Utils.is_skip_text_pressed() \
			or debug_next:
			_on_press_advance()
		
		if next_state:
			return next_state

	func _set_next_state():
		tb.advanced.emit()

		if tb._dlg_text:
			next_state = ActiveState.new(tb, tb._dlg_text)
			tb._dlg_text = null
		else:
			next_state = FadeState.new(tb, false, HiddenState.new(tb))

	func _try_play_text_sound():
		if not tb.text_sound.playing:
			tb.text_sound.play()

	func _reveal_text():
		var delay_src = AccurateDelaySource.new()

		for step in dlg_text.steps:
			if step is int:
				tb.label.visible_characters = step
				_try_play_text_sound()

			elif step is DialogueText.DelayInst:
				if not skip_reveal:
					var call = await delay_src.delay(step.duration)

			elif step is Command:
				var call = tb._context.run_command(step)

				if not skip_reveal:
					await call

		reveal_done = true

		if dlg_text.is_timed():
			_set_next_state()
		else:
			tb.hint_next.show()
