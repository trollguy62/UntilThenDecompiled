extends Label


func _process(delta):
	var datetime = Time.get_datetime_dict_from_unix_time(Game.time)
	var year = datetime["year"]
	var month = datetime["month"]
	var day = datetime["day"]
	var hour = datetime["hour"]
	var minute = datetime["minute"]
	var second = datetime["second"]

	text = "%d-%02d-%02d  %02d:%02d:%02d" % [year, month, day, hour, minute, second]
