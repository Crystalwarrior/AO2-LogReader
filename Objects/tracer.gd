extends Line2D

func do_add_point(pos: Vector2, index: int = -1):
	add_point(pos, index)

func start():
	var tween = create_tween()
	var to_color = Color(modulate)
	to_color.a = 0
	tween.tween_property(self, "modulate", to_color, 1.0)
	tween.tween_callback(self.queue_free)
