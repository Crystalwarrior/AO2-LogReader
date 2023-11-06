extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _gui_input(event):
	if event is InputEventMouseMotion:
		var global_mouse_pos = get_global_mouse_position()
		var old_pos = global_mouse_pos - event.get_relative()
		var global_relative_pos = global_mouse_pos - old_pos
		var rect = get_global_rect()
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			if %ScaleButton.button_pressed:
				var diff = global_mouse_pos - global_position
				size = diff
			else:
				position += global_relative_pos
