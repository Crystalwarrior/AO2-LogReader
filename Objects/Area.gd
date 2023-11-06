extends Control


var resize_offset: Vector2 = Vector2(0, 0)


func _gui_input(event):
	if event is InputEventMouseMotion:
		var global_mouse_pos = get_global_mouse_position()
		var old_pos = global_mouse_pos - event.get_relative()
		var global_relative_pos = global_mouse_pos - old_pos
		var rect = get_global_rect()
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			if %ScaleButton.button_pressed:
				var global_diff = global_mouse_pos - global_position
				var scale_button_diff = global_mouse_pos - %ScaleButton.global_position
				if resize_offset == Vector2(0, 0):
					resize_offset = %ScaleButton.size - scale_button_diff
				size = global_diff + resize_offset
			else:
				position += global_relative_pos
		else:
			if resize_offset != Vector2(0, 0):
				resize_offset = Vector2(0, 0)
