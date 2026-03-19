extends "res://ui/screens/Web/InternalWebPage.gd"

@onready var domain_label = $Margin/VBox/HBoxContainer/Domain


func _ready():
	domain_label.text = link.domain
