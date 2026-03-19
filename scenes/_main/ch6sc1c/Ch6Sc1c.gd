extends Scene

@onready var tvm_screen = $TvmScreen
@onready var camera_main = $Cameras/Main
@onready var camera_exit = $Cameras/Exit


func _ready():
	super._ready()
	Story.emitted.connect(_on_story_emitted)


func _on_story_emitted(name: String, value):
	match name:
		"show_tvm":
			await fader.fade_between(Callable(tvm_screen, "show_screen"))
			await tvm_screen.order_completed
			await fader.fade_between(Callable(tvm_screen, "hide_screen"))
		"line_up":
			camera_main.speed = 1.0
			camera_main.set_target(camera_exit)


func start_exit_short():
	Story.start_short("6.1c.exit")
