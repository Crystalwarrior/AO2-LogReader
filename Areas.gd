extends Control

var area_scene = preload("res://Objects/Area.tscn")

var tracer_scene = preload("res://Objects/tracer.tscn")

var disconnectIcon = preload("res://Assets/disconnect.svg")

var zoomValue = 1

var prevArea
var prevPos

var waitList = {}

func _is_exist(ID, _name):
	for child in self.get_children():
		if child.name == str(ID):
			if child.get_node("%Name").text == "" and _name != null:
				child.get_node("%Name").text = "[%s] %s" % [ID, _name]
			return true
	return false

func create_area(ID, _name):
	if _is_exist(ID, _name):
		return
	if int(ID) == -1:
		return
	var newArea = area_scene.instantiate()
	newArea.name = str(ID)
	if _name != null:
		newArea.get_node("%Name").text = "[%s] %s" % [ID, _name]
	else:
		newArea.get_node("%Name").text = ID
	if prevArea:
		if prevArea.position == prevPos:
			newArea.position += prevArea.position + Vector2(prevArea.size.x + 10, 0)
	self.add_child(newArea)
	prevArea = newArea
	prevPos = prevArea.position


func movement(chara, live, toID, to = null, fromID = null, from = null):
	if fromID != null:
		if !_is_exist(fromID, from):
			create_area(fromID, from)
	if toID != null:
		if !_is_exist(toID, to):
			create_area(toID, to)
		if to != null and self.get_node(toID).get_node("%Name").text != to:
			self.get_node(toID).get_node("%Name").text = "[%s] %s" % [toID, to]
		if from != null and self.get_node(fromID).get_node("%Name").text != from:
			self.get_node(fromID).get_node("%Name").text = "[%s] %s" % [fromID, from]
	if live:
		if chara.mapChar != null:
			var tracer = tracer_scene.instantiate()
			tracer.modulate = chara.color
			self.add_child(tracer)
			tracer.do_add_point(chara.mapChar.global_position + chara.mapChar.size / 2)
			chara.mapChar.reparent(self.get_node(toID).get_node("%CharacterContainer"))
			chara.currentLocationID = toID
			await get_tree().process_frame
			tracer.do_add_point(chara.mapChar.global_position + chara.mapChar.size / 2)
			tracer.start()
		else:
			place_character(chara, chara.get_node("Icon").texture, chara.color, toID, to)


func _on_map_view_camera_zoom_change(value):
	zoomValue = value



func place_character(chara, icon, color, toID, to = null):
	if to != null:
		if !_is_exist(toID, to):
			create_area(toID, to)

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
