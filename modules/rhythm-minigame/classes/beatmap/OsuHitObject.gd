extends RefCounted

const column_count = 4

enum {
	TYPE_HIT_CIRCLE = 0,
	TYPE_SPINNER = 1,  ##unused
	TYPE_SLIDER = 3,  ##unused
	TYPE_HOLD = 7,
}

enum { HIT_SOUND_NORMAL, HIT_SOUND_WHISTLE, HIT_SOUND_FINISH, HIT_SOUND_CLAP }

var x: int = 0  #corresponds to the column in osu!mania ## actual_column = floor(x * columnCount / 512)

var y: int  #unused
var time: int  #in ms
var type: int  #setget set_type #this is a byte, the bit set at position shifted ((type enum above)) places corresponds to the actual type
var hitSound: int  #0: normal, 1: whistle, 2: finish, 3: clap ##in set bits
var objectParams: String  #in hit circles this field is skipped, in holds this field corresponds to the endtime
#var hitSample: String = "0:0:0:0:" #normalSet:additionSet:index:volume:filename

#convenience vars
var column: int = 0:
	get:
		return floor(clamp(x * column_count / 512.0, 0, column_count))
