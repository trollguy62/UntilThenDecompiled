extends Control

const ProcessingScreen = preload("../ProcessingScreen/ProcessingScreen.tscn")

@onready var tvm = find_parent("TVM")
@onready var station_label = $Main/Payment/Header/Container/VBox/StationName
@onready var fare_label = $Main/Payment/AmountReq/Margin/Amount
@onready var fare_alt_label = $Main/Info/PurchaseValue/Amount
@onready var inserted_label = $Main/Payment/AmountIns/Amount

@onready var station_name = tvm.station_names[tvm.selected_station]
@onready var fare = tvm.calc_fare()

var _inserted: int = 0


func _ready():
	tvm.payment_entered.emit()

	var fare_text = "P%d.00" % fare
	fare_label.text = fare_text
	fare_alt_label.text = fare_text
	station_label.text = station_name


func insert(amount: int) -> bool:
	assert(amount > 0)
	if _inserted >= fare:
		return true

	_inserted += amount
	inserted_label.text = "P%d.00" % _inserted
	tvm.insert_coin.play()

	if _inserted >= fare:
		var change = _inserted - fare
		_goto_processing_screen(change)
		return true

	return false


func _goto_processing_screen(change: int):
	await Utils.wait(1.0)
	var screen = ProcessingScreen.instantiate()
	screen.change = change
	tvm.goto(screen)
