extends MarginContainer

enum DayOfWeek { SUNDAY, MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY }

const DAYS_OF_WEEK_ENG = {
	DayOfWeek.SUNDAY: "WEATHERAPP_SUNDAY",
	DayOfWeek.MONDAY: "WEATHERAPP_MONDAY",
	DayOfWeek.TUESDAY: "WEATHERAPP_TUESDAY",
	DayOfWeek.WEDNESDAY: "WEATHERAPP_WEDNESDAY",
	DayOfWeek.THURSDAY: "WEATHERAPP_THURSDAY",
	DayOfWeek.FRIDAY: "WEATHERAPP_FRIDAY",
	DayOfWeek.SATURDAY: "WEATHERAPP_SATURDAY"
}

@export var day_of_week := DayOfWeek.SUNDAY
@export var weather_icons: Array[Texture2D]

@onready var day_of_week_label = $HBox/DayOfWeek
@onready var temp_day_label = $HBox/TempDay
@onready var temp_night_label = $HBox/TempNight
@onready var icon = $HBox/Icon

var weather_idx: int = -1:
	set = set_weather_idx


func _ready():
	day_of_week_label.text = DAYS_OF_WEEK_ENG[day_of_week]
	self.weather_idx = weather_idx


func set_weather_idx(value):
	weather_idx = value

	if is_inside_tree():
		var rng = RandomNumberGenerator.new()
		rng.seed = randi()

		temp_day_label.text = "%d°" % rng.randi_range(30, 36)
		temp_night_label.text = "%d°" % rng.randi_range(26, 32)

		icon.texture = weather_icons[weather_idx]
