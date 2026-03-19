extends SkitContainer

@onready var continue_btn = $CanvasLayer/Container/ContinueBtn
@onready var anim_player = $AnimationPlayer
@onready var sfx_bus_vol_controller = $Audio/SfxBusVolController

var _always_focus_continue_btn := false


func _ready():
	super._ready()
	await wait_for_local("continue_seq")

	anim_player.play("reveal_continue")
	await anim_player.animation_finished

	_always_focus_continue_btn = true
	await continue_btn.pressed

	_always_focus_continue_btn = false
	continue_btn.release_focus()

	await Utils.wait(0.5)
	anim_player.play_backwards("reveal_continue")
	Story.run_command(Command.new("$ fade_out 2.5"))
	
	var tween = create_tween()
	tween.tween_property(sfx_bus_vol_controller, "volume", 0.0, 5.0)
	await tween.finished
	
	emit_local("continue_seq_done")


func _process(_delta):
	if _always_focus_continue_btn:
		continue_btn.grab_focus()
