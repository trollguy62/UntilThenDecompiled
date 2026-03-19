extends RefCounted

const OsuBeatmap = preload("../beatmap/OsuBeatmap.gd")
const OsuEvent = preload("../beatmap/OsuEvent.gd")
const OsuTimingPoint = preload("../beatmap/OsuTimingPoint.gd")
const OsuHitObject = preload("../beatmap/OsuHitObject.gd")

var beatmap: OsuBeatmap = OsuBeatmap.new()


func parse_osu_from_path(file_path: String) -> OsuBeatmap:
	var f: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	if FileAccess.get_open_error() != OK:
		printerr("Error opening file. Error code ", f.get_error(), ".")
		return null

	var magic: String = f.get_line()

	if !magic.begins_with("osu file format "):
		printerr("Not an osu file!")
		return null

	beatmap.BeatmapVersion = magic.substr("osu file format v".length()) as int

	while !f.eof_reached():
		var line: String = f.get_line()
		if line.begins_with("//") || line.begins_with("#") || line.is_empty():
			continue

		match line:
			"[General]":
				_parse_section(f, ": ")
			"[Editor]":
				_parse_section(f, ": ")
			"[Metadata]":
				_parse_section(f, ":")
			"[Difficulty]":
				_parse_section(f, ":")
			"[Events]":
				_parse_events(f)
			"[TimingPoints]":
				_parse_timing_points(f)
			"[Colours]":
				_parse_colors(f)
			"[HitObjects]":
				_parse_hit_objects(f)

	_verify_beatmap()
	print("Finished Parsing Beatmap")
	return beatmap


func _parse_section(f: FileAccess, delimiter: String):
	var fields: Dictionary = _parse_section_fields(f, delimiter)
	_assign(fields)


func _parse_section_fields(f: FileAccess, delimiter: String, maxsplit: int = 0) -> Dictionary:
	var fields: Dictionary = {}

	while !f.eof_reached():
		var line: String = f.get_line()
		if line.is_empty():
			break
		if line.begins_with("//") || line.begins_with("#"):
			continue
		var tokens = line.split(delimiter, true, maxsplit)
		if tokens.size() > 1:
			fields[tokens[0]] = tokens[1]

	return fields


func _parse_section_values(f: FileAccess, delimiter: String, maxsplit: int = 0) -> Array:
	var field_values: Array = []

	while !f.eof_reached():
		var line: String = f.get_line()
		if line.is_empty():
			break
		if line.begins_with("//") || line.begins_with("#"):
			continue
		field_values.append(line.split(delimiter, true, maxsplit))

	return field_values


func _parse_events(f: FileAccess):
	var field_values: Array = _parse_section_values(f, ",", 2)
	var events: Array = []  #Array of OsuEvents

	for i in field_values.size():
		var oe: OsuEvent = OsuEvent.new()
		var raw_v = field_values[i]

		assert(raw_v.size() == 3)

		oe.eventType = raw_v[0]
		oe.startTime = raw_v[1]
		oe.eventParams = raw_v[2]

		events.append(oe)

	beatmap.Events = events


func _parse_timing_points(f: FileAccess):
	var field_values: Array = _parse_section_values(f, ",")
	var timing_points: Array = []  #Array of TimingPoints
	for i in field_values.size():
		var otp: OsuTimingPoint = OsuTimingPoint.new()
		var raw_v = field_values[i]

		assert(raw_v.size() == 8)

		otp.time = raw_v[0]
		otp.beatLength = raw_v[1]
		otp.meter = raw_v[2]
		otp.sampleSet = raw_v[3]
		otp.sampleIndex = raw_v[4]
		otp.volume = raw_v[5]
		otp.uninherited = raw_v[6]
		otp.effects = raw_v[7]

		timing_points.append(otp)

	beatmap.TimingPoints = timing_points


func _parse_colors(f: FileAccess):
	var fields: Dictionary = _parse_section_fields(f, ": ")
	for key in fields:
		var color: Color = Color(0, 0, 0)
		var rgb: PackedStringArray = fields[key].split(",")
		color.r = rgb[0] as float
		color.g = rgb[1] as float
		color.b = rgb[2] as float

		fields[key] = color

	beatmap.Colors = fields


func _parse_hit_objects(f: FileAccess):
	var field_values: Array = _parse_section_values(f, ",")
	var hit_objects: Array = []  #Array of HitObjects
	for i in field_values.size():
		var hit_object: OsuHitObject = _parse_to_hit_object(field_values[i])
		hit_objects.append(hit_object)

#	#x,y,time,type,hitSound,hitSample ##for hit circles
#	#x,y,time,type,hitSound,endTime:hitSample ##for holds
	beatmap.HitObjects = hit_objects


func _parse_to_hit_object(raw_v: PackedStringArray) -> OsuHitObject:
	var ho = OsuHitObject.new()

	ho.x = raw_v[0]
	ho.y = raw_v[1]
	ho.time = raw_v[2]
	ho.type = raw_v[3]
	ho.hitSound = raw_v[4]
	ho.objectParams = raw_v[5]

	return ho


func _try_get_field(which: String, fields: Dictionary):
	if which in fields:
		return fields[which]
	return ""


func _assign(fields: Dictionary):
	for key in fields:
		if key in beatmap:
			beatmap.set(key, fields[key])


func is_valid_osu_file(file_path: String) -> bool:
	var f = FileAccess.open(file_path, FileAccess.READ)

	var header = f.get_line()
	return header.begins_with("osu file format")


func _verify_beatmap():
	##quick tests
	assert(typeof(beatmap.AudioLeadIn) == TYPE_INT)
	assert(beatmap.AudioLeadIn + 1 == int(beatmap.AudioLeadIn) + 1)
	assert(typeof(beatmap.DistanceSpacing) == TYPE_FLOAT)
