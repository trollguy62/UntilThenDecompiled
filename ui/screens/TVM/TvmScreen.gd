extends Panel

const PaymentScreen = preload("res://ui/screens/TVM/PaymentScreen/PaymentScreen.gd")

signal forbidden_station_selected
signal out_of_order_station_selected
signal payment_entered
signal ticket_processed(change)
signal order_completed

const BASE_FARE = 15
const INCR_FARE = 5
const INCR_STEP = 3
const MAX_INCR = 2

var station_names = [
	"Plata", "Bonifacio", "Liamson", "Arellano", "Belica", "Diwa", "Manzanero", "Valino"
]


@onready var container = $ScreenContainer

@onready var beep = $Beep
@onready var insert_coin = $InsertCoin
@onready var process_ticket = $ProcessTicket
@onready var dispense_ticket = $DispenseTicket
@onready var dispense_change = $DispenseChange

var current_station: int = 1
var selected_station: int = -1
var out_of_order_station_indices: Array[int]

func goto(screen: Control):
	if container.get_child_count() == 1:
		var child = container.get_child(0)
		container.remove_child(child)
		child.queue_free()

	container.add_child(screen)


func is_station_forbidden(idx: int):
	return idx != 2


func is_station_out_of_order(idx: int):
	return out_of_order_station_indices.has(idx)


func insert_money(amount: int) -> bool:
	var screen = container.get_child(0)
	if screen is PaymentScreen:
		return screen.insert(amount)
	return false


func calc_fare() -> int:
	var dist = abs(selected_station - current_station)
	var incr = min(MAX_INCR, int(floor((dist - 1.0) / INCR_STEP)))
	return BASE_FARE + incr * INCR_FARE
