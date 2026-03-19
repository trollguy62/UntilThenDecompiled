extends Camera2D

@onready var shake_timer = $Timer
@onready var tween = Threen.new()

var shake_amount = 0
var default_offset = offset

func _ready():
	add_child(tween)
	shake_timer.timeout.connect(_on_timer_timeout)
	set_process(false)

func _process(delta):
	offset = Vector2(randf_range(-shake_amount,shake_amount),randf_range(shake_amount,-shake_amount)) * delta + default_offset

func shake(new_shake,shake_time,shake_limit = 50):
	shake_amount += new_shake
	if shake_amount > shake_limit:
		shake_amount = shake_limit

	shake_timer.wait_time = shake_time
	tween.stop_all()
	set_process(true)
	shake_timer.start()

func _on_timer_timeout():
	shake_amount = 0
	set_process(false)

	tween.interpolate_property(self,"offset",offset,default_offset,0.1,Threen.TRANS_QUAD,Threen.EASE_IN_OUT)
	tween.start()

func _on_mole_hit(score):
	shake(100,0.1,100)
