extends Control

var area_scene = preload("res://Objects/Area.tscn")

var disconnectIcon = preload("res://Assets/disconnect.svg")

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
	var newArea = area_scene.instantiate()
	newArea.name = str(ID)
	if _name != null:
		newArea.get_node("%Name").text = _name
	if prevArea:
		if prevArea.position == prevPos:
			newArea.position += prevArea.position + Vector2(prevArea.size.x + 10, 0)
	self.add_child(newArea)
	prevArea = newArea
	prevPos = prevArea.position


func movement(chara, live, toID, to = null, fromID = null, from = null, line_number = 0):
	if from != null:
		if !_is_exist(from, fromID):
			_create_area(from, fromID)
	if to != null:
		if !_is_exist(to, toID):
			_create_area(to, toID)
	if live:
		if chara.mapChar != null:
			chara.mapChar.reparent(self.get_node(toID).get_node("%CharacterContainer"))
			chara.currentLocationID = toID
		else:
			place_character(chara, chara.get_node("Icon").texture, chara.color, toID, to)


func _on_map_view_camera_zoom_change(value):
	zoomValue = value



func place_character(chara, icon, color, toID, to = null):
	if to != null:
		if !_is_exist(to, toID):
			_create_area(to, toID)

	for area in self.get_children():
		if area.name == toID:
			var newChar = TextureRect.new()
			newChar.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			newChar.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			newChar.custom_minimum_size = Vector2(24,24)
			newChar.name = chara.name
			newChar.tooltip_text = chara.name
			chara.mapChar = newChar
			var disconnection = TextureRect.new()
			disconnection.texture = disconnectIcon
			disconnection.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
			disconnection.layout_mode = 1
			disconnection.set_anchors_preset(Control.PRESET_FULL_RECT)
			disconnection.self_modulate = Color("ffffff8a")
			disconnection.visible = false
			if icon != null:
				newChar.texture = icon
				if newChar.texture.resource_path == "res://Assets/Bean.png":
					newChar.self_modulate = color
			#PLACE CHARACTER
			area.get_node("%CharacterContainer").add_child(newChar)
			newChar.add_child(disconnection)
			break
