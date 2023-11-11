extends Control

var area = preload("res://Objects/Area.tscn")

var zoomValue = 1

var prevArea
var prevPos

var waitList = {}

func _is_exist(_name, ID):
	for child in self.get_children():
		if child.name == str(ID):
			if child.get_node("%Name").text == "" and _name != null:
				child.get_node("%Name").text = _name
			return true
	return false

func _create_area(_name, ID):
	if int(ID) == -1:
		return
	var newArea = area.instantiate()
	newArea.name = str(ID)
	if _name != null:
		newArea.get_node("%Name").text = _name
	if prevArea:
		if prevArea.position == prevPos:
			newArea.position += prevArea.position + Vector2(prevArea.size.x + 10, 0)
	self.add_child(newArea)
	prevArea = newArea
	prevPos = prevArea.position


func _on_main_window_movement(char, from, fromID, to, toID):
#	print("Move " + char.charName + " to " + to)
	if !_is_exist(from, fromID):
		_create_area(from, fromID)
	if !_is_exist(to, toID):
		_create_area(to, toID)
#	char.reparent(self.get_node(toID).get_node("%CharacterContainer"))
	for area in self.get_children():
		for character in area.get_node("%CharacterContainer").get_children():
#			print(character.name)
			if character.name == char.charName:
				character.reparent(self.get_node(toID).get_node("%CharacterContainer"))
				return

	Place_character(char.charName, char.get_node("Icon").texture, char.color, to, toID)


func _on_map_view_camera_zoom_change(value):
	zoomValue = value



func Place_character(charName, icon, color, to, toID):
	if !_is_exist(to, toID):
		_create_area(to, toID)

	for area in self.get_children():
		if area.name == toID:
			var newChar = TextureRect.new()
			newChar.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			newChar.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			newChar.custom_minimum_size = Vector2(24,24)
			newChar.name = charName
			newChar.tooltip_text = charName
			if icon != null:
				newChar.texture = icon
				if newChar.texture.resource_path == "res://Assets/Bean.png":
					newChar.modulate = color
			#PLACE CHARACTER
			area.get_node("%CharacterContainer").add_child(newChar)
			break
