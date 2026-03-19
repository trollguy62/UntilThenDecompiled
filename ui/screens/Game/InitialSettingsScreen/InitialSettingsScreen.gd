extends Control

const SettingsPage = preload("res://ui/components/Game/SettingsPage/SettingsPage.tscn")

@onready var page_container = $PageContainer

@onready var settings_page = SettingsPage.instantiate()


func _ready():
	settings_page.is_initial_settings = true
	page_container.page_stack_changed.connect(_on_page_stack_changed)

	await Utils.wait(1)
	page_container.push(settings_page)


func _on_page_stack_changed():
	if page_container.page_count == 0:
		Game.launch()
