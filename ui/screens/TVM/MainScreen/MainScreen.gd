extends HBoxContainer

const StationScreen = preload("../StationScreen/StationScreen.tscn")

@onready var tvm = find_parent("TVM")
@onready var sjt_btn = $PurchaseTicket/Buttons/VBox/ButtonSJT


func _ready():
	sjt_btn.pressed.connect(_start_order_flow)


func _start_order_flow():
	tvm.beep.play()
	tvm.goto(StationScreen.instantiate())
