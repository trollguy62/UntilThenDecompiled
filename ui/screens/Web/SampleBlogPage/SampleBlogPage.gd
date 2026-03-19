extends "res://ui/screens/Web/StaticWebPage.gd"


func _ready():
	$VBoxContainer/Label1.text = link.query_params.get("v", "Balita ni Jhomari")
