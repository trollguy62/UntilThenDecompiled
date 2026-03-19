extends Marker2D

var enabled = false

var crosshair_pts = [Vector2(0,2), Vector2(0,10),\
					Vector2(0,-2), Vector2(0,-10),\
					Vector2(2,0), Vector2(10,0),\
					Vector2(-2,0), Vector2(-10,0)]

func _process(_delta):
	if enabled:
		global_position = get_global_mouse_position()

func _draw():
	#draw_line(Vector2(0,0), Vector2(0,1), Color.AQUA, 10.0)
	draw_multiline(crosshair_pts, Color.AQUA, 5.0)
	draw_multiline([0,1, 0,50, 0,-1, 0,-5, 1,0, 5,0, -1,0, -5,0], Color.AQUA, 10.0)
	draw_multiline([0,1, 0,50], Color.AQUA, 50.0)
	#draw_circle(Vector2(0,0), 50.0, Color.AQUA)
