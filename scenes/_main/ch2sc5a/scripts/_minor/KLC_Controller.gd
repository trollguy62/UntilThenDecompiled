extends Node2D

@onready var rtl_char_name = $RtlCharName
@onready var rtl_dialogue = $RtlDialogue


func _ready():
	clear()


func say(char_name: String, dialogue: String):
	rtl_char_name.bbcode_text = "[center]%s[/center]" % char_name
	rtl_dialogue.bbcode_text = dialogue
	rtl_dialogue.visible_characters = 0

	await get_tree().process_frame

	var char_count = rtl_dialogue.get_total_character_count()

	for i in range(char_count + 1):
		rtl_dialogue.visible_characters = i
		await Utils.wait(Game.config.text_speed_spk)

	while not Input.is_action_just_pressed("interact"):
		await get_tree().process_frame


func clear():
	rtl_char_name.clear()
	rtl_dialogue.clear()


### Command handler ###
var _command_handler = _run_command


func _enter_tree():
	Story.add_command_handler(_command_handler)


func _exit_tree():
	Story.remove_command_handler(_command_handler)


func _run_command(cmd: Command):
	var params = cmd.params
	var flags = cmd.flags

	match cmd.name:
		"KLC_say":
			var char_name = params[0]
			var dialogue = params[1]
			await say(char_name, dialogue)
		"KLC_clear":
			clear()
		_:
			return Constants.CMD_RETURN_NONE

	return null
