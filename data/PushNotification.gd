extends Node

var app_icon: Texture
var app_name: String
var title: String
var message: String
var priority: int
var route_path: String
var route_payload: Dictionary

enum Priority {
	LOW,  # Not pushed to stack if there's another notif
	MEDIUM,  # Pushed to stack, waits for its turn
	HIGH,  # Pushed immediately after current, stack cleared
	EXTREME,  # Same as HIGH, but shows for longer
	INEVITABLE, # Shows forever
}


func _init(
	app_icon: Texture,
	app_name: String,
	title: String,
	message: String,
	priority: int = Priority.LOW,
	route_path: String = "",
	route_payload: Dictionary = {}
):
	self.app_icon = app_icon
	self.app_name = app_name
	self.title = title
	self.message = message
	self.priority = priority
	self.route_path = route_path
	self.route_payload = route_payload


func open():
	if not route_path.is_empty():
		var navigator = Service.of(Service.NAVIGATOR)
		if navigator:
			navigator.push_named(route_path, route_payload)
