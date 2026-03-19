extends VBoxContainer

signal new_result(result)
signal completed

const HitResult = preload("../../classes/judgment/HitResult.gd")
const HitInput = preload("../../classes/input/HitInput.gd")
const LrcScript = preload("../../classes/lrc/LrcScript.gd")
const RhythmGameConstants = preload("../../utils/RhythmGameConstants.gd")

@onready var lyrics = $Lyrics
@onready var rhythmline = $RhythmLine
@onready var htc_up = $RhythmLine/HitTargetContainerUp
@onready var htc_down = $RhythmLine/HitTargetContainerDown
@onready var htc_left = $RhythmLine/HitTargetContainerLeft
@onready var htc_right = $RhythmLine/HitTargetContainerRight
@onready var hit_target_containers = [htc_up, htc_down, htc_left, htc_right]
@onready var caret = $RhythmLine/Caret
@onready var max_size = size

var timestamp_msec: int = 0:
	set(v):
		lyrics.timestamp_msec = v
		for htc in hit_target_containers:
			if "timestamp_msec" in htc:
				htc.timestamp_msec = timestamp_msec
		timestamp_msec = v


var lrc_script: LrcScript:
	set(v):
		lyrics.lrc_script = v
		lrc_script = v
		size.x = min(size.x, max_size.x)
		show()


var is_caret_visible = false:
	set(v):
		caret.visible = v
		is_caret_visible = v


func _ready():
	hide()
	lyrics.completed.connect(emit_signal.bind("completed"))

	for htc in hit_target_containers:
		htc.new_result.connect(_on_new_result)


func _process(delta):
	#FIXME: hack
	rhythmline.progress = lyrics.progress
	self.is_caret_visible = lyrics.is_active()


func spawn(kht):
	match kht.hit_input.column:
		RhythmGameConstants.COLUMN.DOWN:
			htc_down.spawn(kht)
		RhythmGameConstants.COLUMN.LEFT:
			htc_left.spawn(kht)
		RhythmGameConstants.COLUMN.RIGHT:
			htc_right.spawn(kht)
		RhythmGameConstants.COLUMN.UP:
			htc_up.spawn(kht)


func spawn_hold(hold):
	$RhythmLine/ExtrasContainer.add_child(hold)


func query_progress():
	return lyrics.progress


func clear():
	for htc in hit_target_containers:
		htc.clear()
	for c in $RhythmLine/ExtrasContainer.get_children():
		c.queue_free()

	lyrics.lyric_text = ""


func is_active():
	return lyrics.is_active()


func reset():
	lyrics.progress = 0


#FIXME: hack
func reset_visibility():
	hide()


func _on_new_result(result: HitResult):
	new_result.emit(result)
