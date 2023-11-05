extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _input(event):
	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
#				print("WEWEWEWE")
			if %ScaleButton.button_pressed:
				self.size += event.get_relative() / get_parent().zoomValue
			if %MoveButton.button_pressed:
				self.position += event.get_relative() / get_parent().zoomValue
			
