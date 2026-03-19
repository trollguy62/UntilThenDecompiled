extends RefCounted

var eventType = 0:
	set(v):
		if v == "Video":
			eventType = 1
		else:
			eventType = v as int


var startTime: int = 0

var eventParams: String = ""  #comma-separated list
