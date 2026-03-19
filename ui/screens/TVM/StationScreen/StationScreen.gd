extends Control

const Station = preload("res://ui/screens/TVM/StationScreen/Station.tscn")
const PaymentScreen = preload("../PaymentScreen/PaymentScreen.tscn")

@onready var tvm = find_parent("TVM")
@onready var station_list = $Main/StationSelector/StationList
@onready var cur_station_label = $Main/Summary/CurrentStation
@onready var sel_station_label = $Main/Summary/SelectedStation
@onready var ticket_fare_label = $Main/Summary/TicketFare

@onready var confirm_btn = $Main/Summary/NavButtons/Confirm
@onready var cancel_btn = $Main/Summary/NavButtons/Cancel


func _ready():
	confirm_btn.pressed.connect(_on_confirm)
	cancel_btn.pressed.connect(_on_cancel)

	for i in range(tvm.station_names.size()):
		var st_name = tvm.station_names[i]
		var station = Station.instantiate()

		station.station_name = st_name
		station.current = tvm.current_station == i
		station_list.add_child(station)

		station.selected_changed.connect(_on_selected_station_changed.bind(i))

	_update()


func _on_selected_station_changed(i: int):
	var new_selected = station_list.get_child(i)

	if not new_selected.selected:
		i = -1
	if i != tvm.selected_station and tvm.selected_station >= 0:
		var last_selected = station_list.get_child(tvm.selected_station)
		last_selected.selected = false

	tvm.selected_station = i
	tvm.beep.play()
	_update()


func _update():
	cur_station_label.text = _st_name(tvm.current_station)
	sel_station_label.text = _st_name(tvm.selected_station)
	confirm_btn.disabled = tvm.selected_station == -1

	var fare_text = ""
	var fare_color = Color.BLACK

	if tvm.is_station_out_of_order(tvm.selected_station):
		fare_text = tr("TVM_LABEL_STATION_OOO")
		fare_color = Color.RED
	elif tvm.selected_station >= 0:
		fare_text = "P%d.00" % tvm.calc_fare()

	ticket_fare_label.text = fare_text
	ticket_fare_label.add_theme_color_override("font_color", fare_color)


func _st_name(i: int) -> String:
	return "" if i == -1 else tvm.station_names[i]


func _on_confirm():
	confirm_btn.release_focus()
	var station_name = _st_name(tvm.selected_station)
	if station_name == "":
		return

	if tvm.is_station_out_of_order(tvm.selected_station):
		tvm.out_of_order_station_selected.emit()
		return

	if tvm.is_station_forbidden(tvm.selected_station):
		tvm.forbidden_station_selected.emit()
		return

	var screen = PaymentScreen.instantiate()
	screen.station_name = station_name
	screen.fare = tvm.calc_fare()

	tvm.goto(screen)
	tvm.beep.play()




func _on_cancel():
	var MainScreen = load("res://ui/screens/TVM/MainScreen/MainScreen.tscn")
	tvm.goto(MainScreen.instantiate())
	tvm.beep.play()
