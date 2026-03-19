extends Control

@onready var tvm = find_parent("TVM")
@onready var change_label = $Main/Info/ChangeGiven/AmountContainer/Margin/VBox/Change
@onready var tickets_issued_label = $Main/Info/TicketsIssued/AmountContainer/Margin/VBox/Tickets
@onready var ok_btn = $Buttons/OkBtn

var change: int = 0 : set =  _set_change, get = _get_change
var tickets_issued: int = 1 : set =  _set_tickets_issued, get = _get_tickets_issued


func _ready():
	self.change = change
	self.tickets_issued = tickets_issued

	ok_btn.pressed.connect(_on_ok_pressed)
	tvm.ticket_processed.emit(change)

	if tickets_issued > 0:
		tvm.dispense_ticket.play()
		await tvm.dispense_ticket.finished


	if change > 0:
		tvm.dispense_change.play()
		await tvm.dispense_change.finished


func _set_change(value):
	change = value
	if change_label != null:
		change_label.text = "P%d.00" % change


func _get_change():
	return change


func _set_tickets_issued(value):
	tickets_issued = value
	if tickets_issued_label != null:
		tickets_issued_label.text = str(tickets_issued)


func _get_tickets_issued():
	return tickets_issued


func _on_ok_pressed():
	tvm.beep.play()
	tvm.order_completed.emit()
