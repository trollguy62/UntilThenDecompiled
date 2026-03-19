@tool
extends VBoxContainer

const DAYS_OF_THE_WEEK_ZELLER: Array[String] = ["Saturday", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
const MONTH_DAYS_TABLE = [[31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31],
							[31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]]
const DayLabel = preload("./DayLabel.tscn")

@export var selected_date = {"day": 1, "month": 1, "year": 1}:
	set(v):
		if _is_valid_date(v["day"], v["month"], v["year"]):
			selected_date = v
			_configure(selected_date["month"], selected_date["year"])

@export var weekday: int = -1: #1: Sunday
	set(v):
		var wkday_container = $MarginContainer/WeekdaysContainer
		if v < 0:
			wkday_container.get_child(weekday - 1).button_pressed = false
		else:
			wkday_container.get_child(weekday - 1).button_pressed = true
		weekday = v

@export var month: int = 11:
	set(v):
		month = v
		_configure(month, year)

@export var year: int = 2014:
	set(v):
		year = v
		_configure(month, year)

@export var clamp_to_year: bool = false

var _day_cache: Dictionary = {}


@onready var month_label = $MonthContainer/MonthLabel
@onready var year_label = $YearLabel
@onready var grid = $Grid
@onready var back_btn = $MonthContainer/Back
@onready var forward_btn = $MonthContainer/Forward

func _ready():
	focus_entered.connect(_on_focus_entered)
	back_btn.pressed.connect(_on_back_btn_pressed)
	forward_btn.pressed.connect(_on_forward_btn_pressed)
	selected_date = selected_date


func _on_focus_entered():
	#do nothing
	#just hold focus
	pass

func _on_back_btn_pressed():
	if month <= 1:
		if not clamp_to_year:
			month = 12
			year -= 1
	else:
		month = (month - 1)

func _on_forward_btn_pressed():
	if month >= 12:
		if not clamp_to_year:
			month = 1
			year += 1
	else:
		month = (month + 1)

func _configure(month: int, year: int):
	var month_name = tr(Constants.MONTHS[month - 1])
	month_label.text = month_name
	year_label.text = str(year)
	var day_count = _get_day_count(month, year)
	#calc first day
	var zeller_weekday: int = _zeller(1, month, year)
	#convert to sunday as 0 index
	var converted_weekday = (zeller_weekday + 6) % 7

	_clear()

	#for d in range(converted_weekday, -1, -1):
	for d in converted_weekday:
		#not first day yet, fill with prev month's days
		var p_year = year
		var prev_month
		if month == 1:
			prev_month = 12
			p_year = year - 1
		else:
			prev_month = month - 1

		var prev_month_day_count = _get_day_count(month - 1, p_year)

		var c = Control.new()
		c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		#c.text = str(prev_month_day_count - d)

		if d < converted_weekday:
			grid.add_child(c)

	for d in day_count:
		var l = DayLabel.instantiate()
		l.text = str(d + 1)
		_day_cache[d + 1] = l
		grid.add_child(l)

	_highlight(selected_date)

func _highlight(date: Dictionary):
	if date["month"] == month and date["year"] == year:
		_day_cache[date["day"]].select()
		var current_zeller_weekday: int = _zeller(date["day"], date["month"], date["year"])
		#convert to sunday as 0 index
		var converted_weekday = (current_zeller_weekday + 6) % 7

		#weekday = converted_weekday

func _clear():
	for c in $Grid.get_children():
		c.queue_free()
	_day_cache.clear()
	weekday = -1

func _get_day_of_the_week(day: int, month: int, year: int) -> String:
	return DAYS_OF_THE_WEEK_ZELLER[_zeller(day, month, year)]

#this weekday is a one index int representation of the day of the week starting from monday
#ISO 8601, same as what godot uses internally
func _get_iso_weekday(day: int, month: int, year: int) -> int:
	var d = _zeller(day, month, year)
	return ((d + 5) % 7) + 1

func _zeller(day, month, year):
	var q = day;
	var m = month;
	var k = year % 100;
	var j = year / 100;
	var h = q + 13*(m+1)/5 + k + k/4 + j/4 + 5*j;
	h = h % 7;

	return h

func _get_day_count(month: int, year: int):
	return MONTH_DAYS_TABLE[1][month - 1] if _is_leap(year) else MONTH_DAYS_TABLE[0][month - 1]

func _is_leap(year: int):
	return year % 4 == 0 and (not year % 100 == 0 or year % 400 == 0)

func _is_valid_date(day: int, month: int, year: int):
	return not (day < 1 or day > _get_day_count(month, year) or month < 1 or month > 12)


func __tests():
	assert(_zeller(7, 11, 2023) == 3) 	#nov 7 2023 tues
	assert(_zeller(23, 11, 2014) == 1) #nov 7 2023 sun
	assert(_is_leap(1600))
	assert(not _is_leap(1700))
	assert(_is_leap(2004))
	assert(_get_day_count(2, 1996) == 29) #Feb 1996
	assert(_get_day_count(2, 2001) == 28) #Feb 2001
	assert(_get_day_count(1, 2010) == 31) #Jan 2010
	assert(_get_day_count(6, 1950) == 30) #Jun 1950
	assert(_is_valid_date(29, 2, 2008))
	assert(not _is_valid_date(29, 2, 2005))
	assert(_is_valid_date(31, 1, 2008))
	assert(not _is_valid_date(31, 11, 2008))
