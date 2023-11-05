extends Camera2D

signal zoomChange(value)

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			zoom += Vector2(0.1, 0.1)
			emit_signal("zoomChange", zoom.x)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			zoom -= Vector2(0.1, 0.1)
			emit_signal("zoomChange", zoom.x)
	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
			position -= (event.relative / zoom.x)
