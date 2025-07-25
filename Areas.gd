extends Control

var area_scene = preload("res://Objects/Area.tscn")

var tracer_scene = preload("res://Objects/tracer.tscn")

var disconnectIcon = preload("res://Assets/disconnect.svg")

var map_character_scene = preload("res://Objects/map_character.tscn")

var zoomValue = 1

var waitList = {}

func _is_exist(ID, _name):
	for child in self.get_children():
		if child.name == str(ID):
			if child.get_node("%Name").text == "" and _name != null:
				child.get_node("%Name").text = _name
			return true
	return false

func create_area(ID, _name = null):
	if _is_exist(ID, _name):
		return
	if int(ID) == -1:
		return
	var newArea = area_scene.instantiate()
	self.add_child(newArea)
	newArea.name = str(ID)
	newArea.id.text = "[%s]" % ID
	if _name != null:
		newArea.get_node("%Name").text = _name
	else:
		newArea.get_node("%Name").text = str(ID)
	var index = newArea.get_index()
	var max_columns = 12
	var padding = 10
	newArea.position = Vector2((newArea.size.x + padding) * (index % max_columns), -((newArea.size.y + padding) * floor(index / max_columns)))


func movement(chara, live, toID, to = null, fromID = null, from = null):
	if fromID != null:
		if !_is_exist(fromID, from):
			create_area(fromID, from)
	if toID != null:
		if !_is_exist(toID, to):
			create_area(toID, to)
		if to != null and self.get_node(toID).get_node("%Name").text != to:
			self.get_node(toID).get_node("%Name").text = to
		if from != null and self.get_node(fromID).get_node("%Name").text != from:
			self.get_node(fromID).get_node("%Name").text = from
	if live:
		if not chara.is_visible:
			return
		var old_loc = chara.currentLocationID
		var visible_areas = Globals.get_visible_areas()
		if chara.mapChar != null:
			if not visible_areas.is_empty() and old_loc in visible_areas or toID in visible_areas:
				chara.mapChar.visible = true
				var update = [old_loc, toID]
				await get_tree().process_frame
				#Globals.update_visible_characters(visible_areas + update)
			var tracer = null
			if chara.mapChar.visible:
				#if chara.mapChar.current_tracer:
					#chara.mapChar.current_tracer.queue_free()
				tracer = tracer_scene.instantiate()
				tracer.self_modulate = chara.color
				tracer.self_modulate.a = 0.5
				self.get_parent().add_child(tracer)
				chara.mapChar.current_tracer = tracer
				tracer.do_add_point(chara.mapChar.global_position + chara.mapChar.size / 2)
			chara.mapChar.reparent(self.get_node(toID).get_node("%CharacterContainer"))
			chara.currentLocationID = toID
			if chara.mapChar.visible and tracer:
				await get_tree().process_frame
				tracer.do_add_point(chara.mapChar.global_position + chara.mapChar.size / 2)
				var tracer_char: TextureRect = chara.mapChar.texture_rect.duplicate()
				tracer_char.mouse_filter = Control.MOUSE_FILTER_IGNORE
				tracer.start(tracer_char)
				tracer.finished.connect(tracer.queue_free)
				chara.mapChar.fade(0.0, 1.0, 0.0, 0.2)
			Globals.update_visible_characters(Globals.get_visible_areas())
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
			var newChar = map_character_scene.instantiate()
			#PLACE CHARACTER
			area.get_node("%CharacterContainer").add_child(newChar)
			newChar.name = "[%s] %s" % [chara.aoid, chara.charfolder]
			newChar.tooltip_text = newChar.name
			chara.mapChar = newChar
			if icon != null:
				newChar.texture_rect.texture = icon
				if newChar.texture_rect.texture.resource_path == "res://Assets/Bean.png":
					newChar.self_modulate = color
			break

func save_data():
	var areas = []
	for child in self.get_children():
		areas.append(child.save_data())
	return areas


func load_data(data):
	while self.get_child_count() < data.size():
		create_area(self.get_child_count())
	for i in get_child_count():
		var child = get_child(i)
		child.load_data(data[i])
