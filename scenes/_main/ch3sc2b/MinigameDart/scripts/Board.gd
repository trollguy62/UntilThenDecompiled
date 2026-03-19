extends Sprite2D

@export var score_map: Texture2D


# Does NOT support rotation and flip_h/v
func get_score_at(global_pos: Vector2) -> int:  # [0, 255]
	var im := score_map.get_image()
	var im_size := im.get_size()

	var origin := global_position + offset
	if centered:
		origin -= Vector2(im_size.x, im_size.y) * global_scale / 2.0

	var px = global_pos - origin
	px /= global_scale
	px = Vector2(floor(px.x), floor(px.y))

	var img_rect := Rect2(Vector2.ZERO, im_size)

	if img_rect.has_point(px):
		var color = im.get_pixelv(px)

		return int(floor(color.r * 255))

	return 0
