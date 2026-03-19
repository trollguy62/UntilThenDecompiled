var position: Vector2
var size: float
var route: String


func _init(json: Dictionary):
	var x = float(json.get("x", 0))
	var y = float(json.get("y", 0))

	position = Vector2(x, y)
	size = float(json.get("size", 64))
	route = json.get("route", "")
