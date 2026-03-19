extends PanelContainer

const PushNotification = preload("res://data/PushNotification.gd")

signal opened

# TODO: FlatButton is temporarily disabled
# Proper screen management to follow

var notif: PushNotification

var disabled: bool:
	set(value): button.disabled = value
	get: return button.disabled

@onready var button = $FlatButton
@onready var main = button.child
@onready var app_icon = main.get_node("AppInfo/Icon")
@onready var app_name = main.get_node("AppInfo/Name")
@onready var title = main.get_node("Title")
@onready var message = main.get_node("Message")


func _ready():
	button.pressed.connect(_on_pressed)
	app_icon.texture = notif.app_icon
	app_name.text = notif.app_name
	title.text = notif.title
	message.text = notif.message


func _on_pressed():
	opened.emit()
	notif.open()
