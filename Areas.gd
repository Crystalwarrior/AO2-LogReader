extends Control

var area = preload("res://Objects/Area.tscn")

var zoomValue = 1

var prevArea
var prevPos

func _is_exist(ID):
	for child in self.get_children():
		if child.name == ID:
			return true
	return false

func _create_area(name, ID):
	var newArea = area.instantiate()
	newArea.name = ID
	newArea.get_node("%Name").text = name
	if prevArea:
		if prevArea.position == prevPos:
			newArea.position += prevArea.position + Vector2(prevArea.size.x + 10, 0)
	self.add_child(newArea)
	prevArea = newArea
	prevPos = prevArea.position


func _on_main_window_movement(char, from, fromID, to, toID):
	if !_is_exist(fromID):
		_create_area(from, fromID)
	if !_is_exist(toID):
		_create_area(to, toID)


func _on_map_view_camera_zoom_change(value):
	zoomValue = value
