extends Line2D

signal finished

func do_add_point(pos: Vector2, index: int = -1):
	add_point(pos, index)

func start(trace_object = null):
	var tween = create_tween()
	var to_color = Color(self_modulate)
	to_color.a = 0
	if trace_object:
		self.add_child(trace_object)
		trace_object.global_position = to_global(get_point_position(0)) - trace_object.size/2
		tween.tween_property(trace_object, "self_modulate:a", 1.0, 0.0)
		tween.tween_property(trace_object, "global_position", to_global(get_point_position(1)) - trace_object.size/2, 0.25).set_trans(Tween.TRANS_SINE)
		tween.tween_property(trace_object, "self_modulate:a", 0.0, 0.0)
	tween.tween_property(self, "self_modulate", to_color, 2.0)
	tween.tween_callback(finished.emit)
