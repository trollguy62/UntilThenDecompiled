signal entered()

var name: String
var callback: Callable


func _init(name: String, callback: Callable = Callable()):
	self.name = name
	self.callback = callback


func enter():
	entered.emit()
	if callback.is_valid():
		callback.call()
