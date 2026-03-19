extends HBoxContainer

signal chosen(choice_idx)
signal text_message_sent(text)
signal composition_changed(composition)
signal _sent()

const CHOICE_LIST_TOGGLE_DUR = 0.3
const CHOICE_LIST_FADE_DUR = 0.1
const SCROLL_LOCK_END_OFFSET = 8

const KeystrokeText = preload("res://data/KeystrokeText.gd")

@onready var label = $Panel/Margin/VBox/Label
@onready var choice_list = $Panel/Margin/VBox/ChoiceList
@onready var send_btn = $SendContainer/SendButton
@onready var hint = $Panel/Hint
@onready var tween = Threen.new()
# TODO: Very coupled
@onready var dummy_choice_list = $"../../DummyChoiceList"
@onready var timer = $Timer
@onready var single_keystroke_timer = $SingleKeystrokeTimer
@onready var hold_delay_timer = $HoldDelayTimer

var state: CtfState:
	set = _set_state
var prev_state: String = ""
var choices: Array = []
var text_message: String = ""
var composition: Array
var compose_mode: bool
var run_command: Callable


func _ready():
	add_child(tween)
	self.state = IdleState.new(self)
	hold_delay_timer.timeout.connect(_on_hold_delay_timer_timeout)

	Game.config.text_speed_changed.connect(_update_timer_spk)
	focus_entered.connect(_on_focus_entered)
	_update_timer_spk()


func _on_focus_entered():
	hint.pulse_once()


func _input(ev):
	if ev is InputEventKey:
		#pass only kb events to states
		var next_state = state._input(ev)
		if next_state != null:
			self.state = next_state

	if ev.is_action("c_interact") and not has_focus():
		if ev.pressed:
			hold_delay_timer.start()
		else:
			hold_delay_timer.stop()

func _gui_input(ev):
	var next_state = state._input(ev)
	if next_state != null:
		self.state = next_state


func _process(delta):
	var next_state = await state._process(delta)
	if next_state != null:
		self.state = next_state


func _set_state(next_state):
	if state != null:
		state.exit()
	state = next_state
	state.enter()


func _emit_chosen(choice_idx: int):
	chosen.emit(choice_idx)


func _emit_text_message(text):
	text_message_sent.emit(text)


func _play_type_sound():
	$SoundType.play()


func _play_chat_choice_sound():
	$SoundChatChoice.play()


func _update_timer_spk():
	timer.wait_time = Game.config.text_speed_spk

func _on_hold_delay_timer_timeout():
	grab_focus()

func get_composition() -> String:
	var composition = ""
	for compose in self.composition:
		composition += compose
	return composition


func clear_composition():
	composition.clear()
	label.text = ""


func composition_erase_last():
	var from_text = get_composition()
	composition.pop_back()
	var to_text = get_composition()

	assert(from_text.begins_with(to_text))

	var del_text = from_text.substr(to_text.length())
	var raw_text = "[:%s]" % del_text
	var keystr = KeystrokeText.new(raw_text)

	for i in range(0, del_text.length()):
		keystr.steps.pop_front()

	self.state = TypeState.new(self, keystr, true)


func request_send():
	# TODO: We have reached the point of desperation. Refactor.
	self.state = PreSendState.new(self, label.text, true)
	await self._sent
	return true


func start_keystroke_timer():
	single_keystroke_timer.start()


func stop_keystroke_timer():
	single_keystroke_timer.stop()


func is_keystroke_timer_stopped():
	return single_keystroke_timer.is_stopped()


### CtfStates ###
const State = preload("res://data/State.gd")


class CtfState:
	extends State
	var choice_text_field

	func _init(choice_text_field):
		self.choice_text_field = choice_text_field

	func has_focus() -> bool:
		return choice_text_field.is_visible_in_tree()


class IdleState:
	extends CtfState
	var from_choices: bool

	func _init(ctf, from_choices: bool = false):
		super(ctf)
		self.from_choices = from_choices

	func enter():
		if not choice_text_field.compose_mode:
			choice_text_field.label.text = ""

	func _process(delta):
		var choices = choice_text_field.choices
		var text = choice_text_field.text_message

		if text.length() > 0:
			choice_text_field.text_message = ""

			text = Utils.replace_edges(text, "_", " ")

			return PreTypeState.new(choice_text_field, text, from_choices)
		elif choices.size() > 0:
			choice_text_field.choices = []
			return ChoiceState.new(choice_text_field, choices)


class ChoiceState:
	extends CtfState
	var choices: Array
	var choice_idx = -1
	var next_state

	var choice_list
	var dummy_list
	var label
	var tween: Threen

	var expand_size = 30

	func _init(ctf, choices):
		super(ctf)
		self.choices = choices
		choice_list = choice_text_field.choice_list
		dummy_list = choice_text_field.dummy_choice_list
		label = choice_text_field.label
		tween = choice_text_field.tween

	func enter():
		# Suppress if invisible, or else, height 0 will be calculated from dummy_list
		while not dummy_list.is_visible_in_tree():
			await Utils.wait_frames(1)
		# TODO: Calculate height without rendering, refactor if non-hacky solution found

		var label_visible = (
			choice_text_field.compose_mode
			and not choice_text_field.label.text.is_empty()
		)

		choice_text_field._play_chat_choice_sound()

		dummy_list.show_top_margin = label_visible
		dummy_list.custom_minimum_size.x = choice_list.size.x
		dummy_list.choices = choices
		# Absolutely has to wait 2 frames to account for the top margin
		await Utils.wait_frames(2)

		var sy = dummy_list.size.y
		dummy_list.clear_choices()

		choice_text_field.label.visible = label_visible
		choice_list.modulate.a = 0

		var from_size = Vector2(0, label.get_line_height())
		var to_size = Vector2(0, sy)

		if label_visible:
			from_size = Vector2.ZERO

		tween.interpolate_property(
			choice_list,
			"custom_minimum_size",
			from_size,
			to_size,
			CHOICE_LIST_TOGGLE_DUR,
			Threen.TRANS_QUAD,
			Threen.EASE_IN_OUT
		)
		tween.start()
		await tween.tween_completed

		choice_list.show_top_margin = label_visible
		choice_list.choices = choices

		tween.interpolate_property(
			choice_list,
			"modulate",
			Color.TRANSPARENT,
			Color.WHITE,
			CHOICE_LIST_FADE_DUR,
			Threen.TRANS_LINEAR,
			Threen.EASE_IN
		)
		tween.start()
		await tween.tween_completed

		dummy_list.size.y = 0  # Reset size for next measurements
		choice_list.choice_pressed.connect(_on_choice_pressed)

	func _process(delta):
		return next_state

	func _exit():
		tween.interpolate_property(
			choice_list,
			"modulate",
			Color.WHITE,
			Color.TRANSPARENT,
			CHOICE_LIST_FADE_DUR,
			Threen.TRANS_LINEAR,
			Threen.EASE_IN
		)
		tween.start()
		await tween.tween_completed

		var from_size = choice_list.size
		var to_size = Vector2(0, label.get_line_height())

		if choice_text_field.label.visible:
			to_size = Vector2.ZERO

		choice_list.show_top_margin = false
		choice_list.custom_minimum_size = from_size
		choice_list.clear_choices()

		tween.interpolate_property(
			choice_list,
			"custom_minimum_size",
			from_size,
			to_size,
			CHOICE_LIST_TOGGLE_DUR,
			Threen.TRANS_QUAD,
			Threen.EASE_IN_OUT
		)
		tween.start()
		await tween.tween_completed

		choice_text_field.label.visible = true
		choice_list.custom_minimum_size = Vector2.ZERO

		choices[choice_idx].enter()
		choice_text_field._emit_chosen(choice_idx)
		next_state = IdleState.new(choice_text_field, true)

	func _on_choice_pressed(idx):
		if choice_idx < 0:
			choice_idx = idx
			_exit()


class PreTypeState:
	extends CtfState
	const KeystrokeText = preload("res://data/KeystrokeText.gd")

	var type_str: String
	var from_choices: bool

	func _init(ctf, type_str, from_choices: bool = false):
		super(ctf)
		self.type_str = type_str
		self.from_choices = from_choices

	func enter():
		if not choice_text_field.compose_mode or choice_text_field.composition.size() == 0:
			choice_text_field.label.modulate.a = 0.6
			choice_text_field.label.text = "CHAT_START_TYPING"

		choice_text_field.label.custom_minimum_size.y = 0
		choice_text_field.hint.pulsing = not from_choices

		if not from_choices:
			choice_text_field._play_chat_choice_sound()

	func _process(delta):
		if (Input.is_action_pressed("c_interact") or Utils.is_skip_text_pressed()) \
				and choice_text_field.has_focus():
			return _next()

	func _input(ev):
		if (
			ev is InputEventKey
			and ev.pressed
			and has_focus()
			and not Input.is_action_pressed("pause")
		):
			return _next()

	func _next():
		var keystr = KeystrokeText.new(type_str)
		return TypeState.new(choice_text_field, keystr)

	func exit():
		choice_text_field.label.modulate.a = 1
		choice_text_field.hint.pulsing = false

		if choice_text_field.compose_mode:
			choice_text_field.label.text = choice_text_field.get_composition()
		else:
			choice_text_field.label.text = ""


class EraseState:
	extends CtfState
	const KeystrokeText = preload("res://data/KeystrokeText.gd")

	var from_text: String
	var to_text: String
	var keystr: KeystrokeText
	var inst

	var is_erasing: bool
	var erase_complete: bool

	func _init(ctf, from_text, to_text):
		super(ctf)
		self.from_text = from_text
		self.to_text = to_text

	func enter():
		choice_text_field.label.custom_minimum_size.y = 0
		choice_text_field.label.text = from_text

		# erasing
		while from_text.length() > to_text.length():
			await Utils.wait(Game.config.text_speed_spk)
			if is_erasing:
				from_text = from_text.substr(0, from_text.length() - 1)
				choice_text_field.label.text = from_text
				choice_text_field._play_type_sound()

		erase_complete = true

	func _process(delta):
		if erase_complete:
			return IdleState.new(choice_text_field)

		is_erasing = Input.is_action_pressed("ui_accept") or Utils.is_skip_text_pressed()


class TypeState:
	extends CtfState
	const AccurateDelaySource = preload("res://components/AccurateDelaySource.gd")
	const KeystrokeText = preload("res://data/KeystrokeText.gd")

	var keystr: KeystrokeText
	var compose_erase_mode := true

	var single_keystroke := false
	var continuous_keystroke := false
	var next_state

	var last_interact_state = false

	func _init(ctf, keystr, compose_erase_mode = false):
		super(ctf)
		self.keystr = keystr
		self.compose_erase_mode = compose_erase_mode

	func enter():
		var delay_src = AccurateDelaySource.new()
		var step_count = keystr.steps.size()
		var has_typed = false

		var composition = choice_text_field.get_composition()

		for i in range(step_count):
			var inst = keystr.steps[i]
			var is_last_step = i == step_count - 1

			if inst is KeystrokeText.TextInst:
				if has_typed:
					while not _has_keystroke():
						await Utils.wait(0)
				else:
					has_typed = true

				choice_text_field.label.text = composition + inst.text
				choice_text_field._play_type_sound()

				if continuous_keystroke and not is_last_step:
					await delay_src.delay(Game.config.text_speed_spk)
				elif single_keystroke:
					single_keystroke = false
			elif inst is KeystrokeText.ContinuousDelayInst:
				if continuous_keystroke:
					await Utils.wait(inst.delay)
			elif inst is Command:
				await choice_text_field.run_command.call(inst)

		if continuous_keystroke:
			await Utils.wait(0.15)

		if not choice_text_field.compose_mode:
			next_state = PreSendState.new(choice_text_field, keystr.final_text)
		else:
			# TODO: Entire compose system could be better. Refactor
			if not compose_erase_mode:
				choice_text_field.composition.append(keystr.final_text)
			choice_text_field._emit_text_message("bruh!!")  # ink.advance()
			next_state = IdleState.new(choice_text_field)

	func _has_keystroke():
		return (continuous_keystroke or single_keystroke) and has_focus()

	func _process(delta):
		#FIXME: this entire block looks ugly
		if _should_start_keystroke_timer():
			choice_text_field.start_keystroke_timer()
			last_interact_state = true

		if (Input.is_action_just_released("c_interact") and choice_text_field.has_focus()) or Input.is_action_just_released("k_interact"):
			single_keystroke = true
			choice_text_field.stop_keystroke_timer()
			last_interact_state = false

		continuous_keystroke = (
				((Input.is_action_pressed("c_interact") or compose_erase_mode) and choice_text_field.has_focus())) or \
				((Input.is_action_pressed("k_interact") or compose_erase_mode) and choice_text_field.is_keystroke_timer_stopped()) or \
				((Utils.is_skip_text_pressed() or compose_erase_mode) and choice_text_field.is_keystroke_timer_stopped())
		#
		return next_state

	func _input(ev):
		if (
			ev is InputEventKey
			and ev.pressed
			and not ev.echo
			and not Input.is_action_pressed("pause")
		):
			single_keystroke = true

	func _should_start_keystroke_timer():
		return ((last_interact_state != Input.is_action_pressed("c_interact") and not last_interact_state and choice_text_field.has_focus() and choice_text_field.is_keystroke_timer_stopped() and not continuous_keystroke)) or \
		(Input.is_action_just_pressed("k_interact") and choice_text_field.is_keystroke_timer_stopped() and not continuous_keystroke)

class PreSendState:
	extends CtfState
	var type_str = ""
	var next_state = false
	var compose_mode = false

	func _init(ctf, type_str, ignore_compose_mode = false):
		super(ctf)
		self.type_str = type_str

		if not ignore_compose_mode:
			compose_mode = choice_text_field.compose_mode

		if compose_mode:
			self.type_str = choice_text_field.get_composition()

	func enter():
		choice_text_field.timer.stop()
		choice_text_field.label.text = type_str

		if compose_mode or type_str.is_empty():
			next_state = true
		else:
			choice_text_field.send_btn.disabled = false
			choice_text_field.send_btn.pressed.connect(_on_send_pressed)

	func _on_send_pressed():
		next_state = true

	func _process(delta):
		if has_focus() and (Input.is_action_pressed("ui_accept") or Utils.is_skip_text_pressed()):
			next_state = true

		if next_state:
			choice_text_field._sent.emit()
			#FIXME: hack
			choice_text_field.prev_state = "PreSendState"
			#
			return IdleState.new(choice_text_field)

	func exit():
		choice_text_field.send_btn.disabled = true
		choice_text_field._emit_text_message(type_str)
