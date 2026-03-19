extends Node

const EPSILON = 0.001
const PLAYER_COLLISION_LAYER = 2
const PLAYTHROUGH_COUNT = 3
const OLD_SAVE_VERSION_MAGIC = "42"
const COLOR_BG_FB = Color("#CCD5D9EA")
const RECOMMENDED_VK_VERSION = "1.3.262"

const MONTHS = [
	"MONTH_JAN",
	"MONTH_FEB",
	"MONTH_MAR",
	"MONTH_APR",
	"MONTH_MAY",
	"MONTH_JUN",
	"MONTH_JUL",
	"MONTH_AUG",
	"MONTH_SEP",
	"MONTH_OCT",
	"MONTH_NOV",
	"MONTH_DEC"
]

const MONTHS_SHORT = [
	"MONTH_SHORT_JAN",
	"MONTH_SHORT_FEB",
	"MONTH_SHORT_MAR",
	"MONTH_SHORT_APR",
	"MONTH_SHORT_MAY",
	"MONTH_SHORT_JUN",
	"MONTH_SHORT_JUL",
	"MONTH_SHORT_AUG",
	"MONTH_SHORT_SEP",
	"MONTH_SHORT_OCT",
	"MONTH_SHORT_NOV",
	"MONTH_SHORT_DEC"
]

const CHOICE_KEYS = ["choice_1", "choice_2", "choice_3", "choice_4"]

const SETTINGS_CONFIG_PATH = "user://settings.res"
const INPUT_CONFIG_PATH = "user://input.res"
const SAVEGAME_PATH = "user://savegame.res"
const SAVEGAME_BAK_PATH = "user://savegame.bak.res"
const BASE_STORY_DIR_PATH = "res://assets/story"

const MALE = 0
const FEMALE = 1

const UNIVERSAL_FOCUS = "main"

const DEFAULT_LOCALE = "en"
const LOCALES = {
	"de": "Deutsch",
	"en": "English",
	"es": "Español",
	"fil": "Filipino",
	"fr": "Français",
	"it": "Italiano",
	"ja": "日本語",
	"zh-CN": "简体中文",
	"id": "Bahasa Indonesia",
}

##note: set default keybinds in ProjectSettings##
# When adding actions here, do NOT change or shuffle the existing order. Simply insert.
const REMAPPABLE_ACTIONS = [
	{"action": "move_up", "name": "SETTINGS_CTRL_UP", "group": ""},
	{"action": "move_left", "name": "SETTINGS_CTRL_LEFT", "group": ""},
	{"action": "move_down", "name": "SETTINGS_CTRL_DOWN", "group": ""},
	{"action": "move_right", "name": "SETTINGS_CTRL_RIGHT", "group": ""},
	{"action": "interact", "name": "SETTINGS_CTRL_INTERACT", "group": ""},
	{"action": "skip_text", "name": "SETTINGS_CTRL_SKIP_TEXT", "group": "", "ng_plus_only": true},
	{"action": "rhythm_up", "name": "SETTINGS_CTRL_RHYTHM_UP", "group": "Rhythm"},
	{"action": "rhythm_down", "name": "SETTINGS_CTRL_RHYTHM_DOWN", "group": "Rhythm"},
	{"action": "rhythm_left", "name": "SETTINGS_CTRL_RHYTHM_LEFT", "group": "Rhythm"},
	{"action": "rhythm_right", "name": "SETTINGS_CTRL_RHYTHM_RIGHT", "group": "Rhythm"},
]

@onready var REGEX_STORE_PATH := RegEx.create_from_string("(\\w+)\\:\\/\\/(.+)")
@onready var REGEX_COMMAND := RegEx.create_from_string("\\$\\s+([a-zA-Z0-9._-]+)\\s*(.*)\\s*")
@onready var REGEX_SUBSTORY_TAG := RegEx.create_from_string("([a-zA-Z0-9_]+)\\s*:\\s*(.+)")
@onready var REGEX_DIALOGUE := RegEx.create_from_string("(?'char_key'[a-zA-Z0-9:_-]+)\\s*(?:\\((?'duration'.+)\\))?\\:\\s*(?'text'.+)")
@onready var REGEX_CHAT := RegEx.create_from_string("(\\w+)\\s*\\:\\s*(.+)")

@onready var CMD_RETURN_NONE := RefCounted.new()

var BUS_IDX_MASTER = AudioServer.get_bus_index("Master")
var BUS_IDX_MUSIC = AudioServer.get_bus_index("Music")
var BUS_IDX_SFX = AudioServer.get_bus_index("SFX")


func _enter_tree():
	print("Until Then %s" % ProjectSettings.get("application/config/version"))
	print("-------------------")
