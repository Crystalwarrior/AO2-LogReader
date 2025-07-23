extends Control

@onready var logview_window: Window = %LogViewWindow
@onready var logview: TextEdit = %LogViewLabel
@onready var parsed_view_window: Window = %ParsedViewWindow
@onready var parsed_view: RichTextLabel = %ParsedViewLabel
@onready var file_dialog: FileDialog = %FileDialog
@onready var folder_dialog: FileDialog = %FolderDialog
@onready var map_file_dialog: FileDialog = %MapFileDialog
@onready var layout_file_dialog: FileDialog = %LayoutFileDialog
@onready var timeline = %TimelineBar
@onready var areas = $"../../Areas"
@onready var currentLabel = %CurrentTime
@onready var endLabel = %EndTime
@onready var delay = %Delay
@onready var playButton = %">"
@onready var playbackButton = %"<"

signal swapMap(path)

signal zoom(amt)

signal reset_camera()

signal map_change_color(color:Color)

signal save_layout()
signal load_layout(layout)

const colors = ["#888888","#00FF00","#0000FF","#FF0000","#01FFFE","#FFA6FE","#FFDB66","#006401","#010067","#95003A","#007DB5","#FF00F6","#99EEE8","#774D00","#90FB92","#0076FF","#D5FF00","#FF937E","#6A826C","#FF029D","#FE8900","#7A4782","#7E2DD2","#85A900","#FF0056","#A42400","#00AE7E","#683D3B","#BDC6FF","#263400","#BDD393","#00B917","#9E008E","#001544","#C28C9F","#FF74A3","#01D0FF","#004754","#E56FFE","#788231","#0E4CA1","#91D0CB","#BE9970","#968AE8","#BB8800","#43002C","#DEFF74","#00FFC6","#FFE502","#620E00","#008F9C","#98FF52","#7544B1","#B500FF","#00FF78","#FF6E41","#005F39","#6B6882","#5FAD4E","#A75740","#A5FFD2","#FFB167","#009BFF","#E85EBE",]

var characterNode = preload("res://Objects/Character.tscn")

var asset_folder_path: String

var current_file: FileAccess
var current_file_path: String
var last_date_modified

var hostname: String

var initial_logread = false
var shownames: Dictionary = {}
var characters = []
var idCounter = 0
var movements = []
var startTime
var endTime = 0
var timer = 0
var playing
var playing_backward
var areasRead
var areasBegin = ["[1", "[2", "[3", "[4", "[5", "[6", "[7", "[8", "[9", "[0", "[CM]", "[GM]", "[M]", "=== ", "  ◽", "  ◾"]

var last_linecount

func _process(_delta):
	if current_file_path and last_date_modified != FileAccess.get_modified_time(current_file_path):
		if reload_logfile():
			while current_file.get_position() < current_file.get_length():
				var line = current_file.get_line()
				# end-of-file newline gets treated as a separate line, and shows up as blank
				if line == "":
					continue
				parse_line(line)
				logview.text += "\n"+line
			if !shownames.is_empty():
				_find_avatars()
			scroll_to_last_line()
	if playing and timeline.value != endTime - startTime:
		if timer <= 0:
			timeline.value += 1
			timer = delay.value * 60
		else:
			timer -= 1

	if playing_backward == true and timeline.value != 0:
		if timer <= 0:
			timeline.value -= 1
			timer = delay.value * 60
		else:
			timer -= 1


func read_ini(ini_path, file_name):
	var config = FileAccess.open(ini_path, FileAccess.READ)
	var in_options = false
	while not config.eof_reached():
		var line = config.get_line()
		if line.begins_with("["):
			in_options = line.strip_edges().to_lower() == "[options]"
		if in_options:
			var split = line.split("=")
			if split.size() > 1 and split[0].strip_edges() == "showname":
				var showname = split[1].strip_edges()
				if showname and showname != file_name:
					shownames[showname] = file_name


func generate_shownames():
	shownames.clear()
	var dir = DirAccess.open(asset_folder_path + "/characters")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				var ini_path = dir.get_current_dir() + "/" + file_name + "/char.ini"
				if FileAccess.file_exists(ini_path):
					read_ini(ini_path, file_name)
				else:
					dir.change_dir(file_name)
					for subdir in dir.get_directories():
						ini_path = dir.get_current_dir() + "/" + subdir + "/char.ini"
						if FileAccess.file_exists(ini_path):
							read_ini(ini_path, dir.get_current_dir().get_file() + "/" + subdir)
					dir.change_dir("../")
			file_name = dir.get_next()
	_find_avatars()

func parse_line(line):
	areasRead = false

	for beginning in areasBegin:
		if line.begins_with(beginning):
			areasRead = true
			break

	if areasRead:
		if line.begins_with("=== "):
			var areaName = line.split("]")[1].split("(")[0].strip_edges()
			var areaID = line.split("]")[0].split("[")[1].strip_edges()
			areas.create_area(areaName, areaID)
		elif not line.contains("users:"):
			var charID
			var showName
			var folderName
			if line.begins_with("[GM") or line.begins_with("[M") or line.begins_with("[CM"):
				charID = line.split("]")[1].split("[")[1]
				showName = line.split("]")[2].split("<")[0].split(":")[0].strip_edges()
				folderName = line.split(":")[0].split("<")[0].split("(")[-1].split(")")[0].split("]")[-1].strip_edges()
			else:
				charID = line.split("]")[0].split("[")[1]
				showName = line.split("]")[1].split("<")[0].split(":")[0].split("(")[0].strip_edges().lstrip("\"").rstrip("\"")
				folderName = line.split(":")[0].split("<")[0].split("(")[-1].split(")")[0].split("]")[-1].strip_edges()
			var areaNameArray = [showName]
			if showName != folderName:
				areaNameArray.append(folderName)
			var areaChar = _find_character(areaNameArray)
			if areaChar == null:
				var newChar = create_character(charID)
				for currentName in areaNameArray:
					newChar.add_name(currentName)
				newChar.charfolder = folderName
			else:
				areaChar.charfolder = folderName
	parsed_view.newline()
	if not line.begins_with("[") or not line.contains("GMT]"):
		parsed_view.add_text(line)
		return
	var is_ooc = false
	if line.begins_with("[OOC]"):
		is_ooc = true
		line = line.substr("[OOC]".length())
	var timestamp = line.substr(0, line.find("]"))
	line = line.substr(timestamp.length()+1)
	var message = line.substr(line.find(":")+1).strip_edges()
	var speaker = line.substr(0, line.find(":")).strip_edges()
	var talkAreaID = null
	# OOC message from a different area will contain info where the message was said
	# There are also OOC tags such as [GM] etc.
	if speaker.begins_with("["):
		speaker = speaker.substr(line.find("]")).strip_edges()
		pass
	if message.contains("}}}["):
		talkAreaID = message.split("}}}[")[1].split("]")[0]

	var italics = false
	var avatar = null
	var charfolder = ""
	var currentCharacter
	if is_ooc:
		if not hostname and (message.begins_with("===") or message.begins_with("Changed to")) and speaker != "[Global log]":
			hostname = speaker
		if speaker == hostname:
			if message.ends_with("has disconnected."):
				var aoid = message.split("]")[0].lstrip("[")
				currentCharacter = _find_character_by_aoid(aoid)
				if currentCharacter == null:
					currentCharacter = create_character(aoid)
					currentCharacter.add_name(message.split("]")[1].split(" has")[0].strip_edges())
				currentCharacter.set_disconnect_state(true)
	else:
		var actions = ["shouts", "has "]
		for action in actions:
			if speaker.find(action) > -1:
				italics = true
				speaker = speaker.substr(0, speaker.find(action))
				break

		var showname = speaker.substr(0, speaker.find("(")).strip_edges()
		charfolder = showname
		if showname != speaker:
			charfolder = speaker.substr(showname.length()+1).strip_edges().trim_prefix("(").trim_suffix(")")
		if charfolder in shownames:
			charfolder = shownames[charfolder]
		if charfolder:
			avatar = get_speakerIcon(charfolder)
			if avatar is ImageTexture:
					# Add image to the bbcode tag stack
				parsed_view.add_image(avatar, 24, 24)
			#else:
				#push_warning("Couldn't find char_icon for %s (%s)" % [asset_folder_path + "/characters/" + charfolder + "/char_icon.png", message])
	if italics:
		parsed_view.push_italics()
	if speaker == hostname:
		parsed_view.push_color(Color.DEEP_SKY_BLUE)
	else:
		parsed_view.push_color(Color.AQUAMARINE)
	# Colored name
	parsed_view.add_text(speaker)
	# pop color
	parsed_view.pop()
	parsed_view.add_text(": ")
	parsed_view.add_text(message.replace("{", "").replace("}", ""))
	if italics:
		parsed_view.pop()

	if !is_ooc or line.contains("moves from") or line.contains("Attempting to kick"):
		var aoid = null
		var nameArray
		if speaker == hostname and line.contains("moves from"):
			aoid = line.split("]")[0].split("[")[1]
			nameArray = [line.split("]")[1].lstrip(" ").split("moves from")[0].strip_edges()]
		else:
			nameArray = _clean_name(speaker)

		if nameArray.is_empty():
			return
		currentCharacter = _find_character(nameArray, aoid)
		if currentCharacter == null:
			#CREATE NEW CHARACTER
			currentCharacter = create_character(aoid)
		if currentCharacter.disconnected == true or aoid != null:
			currentCharacter.set_aoid(aoid)
			currentCharacter.set_disconnect_state(false)
		if charfolder != "" and not shownames.is_empty():
			currentCharacter.charfolder = charfolder
			currentCharacter.add_name(charfolder)
		if talkAreaID != null and currentCharacter.currentLocationID != talkAreaID:
			movements.append([currentCharacter.id, currentCharacter.currentLocationID, talkAreaID, _convert_time(timestamp)])
			currentCharacter.currentLocationID = talkAreaID
			var live = timeline.value == timeline.max_value
			areas.movement(currentCharacter, live, talkAreaID)
		for currentName in nameArray:
			if currentName != "":
				currentCharacter.add_name(currentName)
				if charfolder != "" and !currentCharacter.names.has(charfolder):
					currentCharacter.add_name(charfolder)
		if speaker == hostname and line.contains("Attempting to kick"):
			aoid = message.split("[")[1].split("]")[0]
			nameArray = [message.split("]")[1].split("from")[0].strip_edges()]
			currentCharacter = _find_character(nameArray, aoid)
			if currentCharacter:
				for currentName in nameArray:
					currentCharacter.add_name(currentName)
				var fromID = message.split("[")[2].split("]")[0]
				var from = message.split("]")[2].split("to")[0].strip_edges()
				var toID = message.split("[")[3].split("]")[0]
				var to = message.split("]")[3].split(".")[0].strip_edges()
				var live = timeline.value == timeline.max_value
				areas.movement(currentCharacter, live, toID, to, fromID, from)

		if speaker == hostname and line.find("moves from") != -1:
			var from = line.split("] ")[2].split(" to")[0]
			var fromID = line.split("] ")[1].split("[")[1]
			var to = line.split("] ")[3].rsplit(".")[0]
			var toID = line.split("] ")[2].split("[")[1]
			var time = _convert_time(timestamp)
			if startTime == null:
				startTime = time
			if time > endTime:
				endTime = time
			if currentCharacter.currentLocationID == null:
				movements.append([currentCharacter.id, fromID, fromID, startTime, line])
			movements.append([currentCharacter.id, fromID, toID, time, line])
			var live = timeline.value == timeline.max_value
			areas.movement(currentCharacter, live, toID, to, fromID, from)
			_update_timeline(live)

func _convert_time(timeStamp):
	var timeString
	var timeArray = timeStamp.split(" ")
	#2023-1-9 00:39:43
	timeString = timeArray[4] + "-1-" + timeArray[2] + " " + timeArray[3]
	var time = Time.get_unix_time_from_datetime_string(timeString)
	return time

func create_character(aoid = null):
# PUT CHARACTER INTO THE LIST
	var newChar = characterNode.instantiate()
	newChar.id = idCounter
	idCounter += 1
	if newChar.id < colors.size():
		# pull color from the color table
		newChar.set_color(Color(colors[newChar.id]))
	else:
		# just generate a random color
		newChar.set_color(Color.from_hsv(randf(), 1.0, 0.5 + randf() * 0.5))
	if aoid:
		newChar.set_aoid(aoid)
	%CharacterList.add_child(newChar)
	characters.append(newChar)

	return newChar

func _get_avatar(chara):
	if chara.charfolder:
		return get_speakerIcon(chara.charfolder)
	if chara.avatar:
		return chara.avatar
	return get_speakerIcon(chara.current_name)

func _set_avatar(chara):
	var avatar = _get_avatar(chara)
	if avatar != null:
		chara.set_avatar(avatar)

func _find_avatars():
	for character in characters:
		_set_avatar(character)

func _find_character(nameArray, aoid = null):
	for character in characters:
		for alias in character.names:
			if aoid != null and character.aoid != null and character.aoid != aoid:
				continue
			if alias in nameArray:
				return character
	return null

func _find_character_by_aoid(aoid):
	for character in characters:
		if character.aoid == aoid:
			return character
	return null

func _clean_name(speaker):
	var speakerArray = []
	if speaker == "$":
		return []
	if speaker.split("(").size() > 1:
		var splitArray = speaker.split("(")
		speaker = splitArray[0].strip_edges() + "(" + splitArray[splitArray.size()-1].strip_edges()
		speakerArray.append(splitArray[0].strip_edges())
		speakerArray.append(splitArray[splitArray.size()-1].strip_edges().rstrip(")"))
	elif speaker != "":
		speakerArray.append(speaker.strip_edges())
	return speakerArray

func get_speakerIcon(charfolder: String):
	if charfolder.is_empty():
		return null
	var speaker_icon = asset_folder_path + "/characters/" + charfolder + "/char_icon.png"
	if FileAccess.file_exists(speaker_icon):
		# TODO: cache this, ideally by using Godot's resource system properly
		var image = Image.load_from_file(speaker_icon)
		return ImageTexture.create_from_image(image)
	else:
		return null

func parse_logfile():
	initial_logread = true
	parsed_view.clear()
	hostname = ""
	var text = current_file.get_as_text()
	logview.text = text
	var lines = text.strip_edges().split("\n")
	for i in lines.size():
		var line = lines[i]
		parse_line(line)
	initial_logread = false
	if !shownames.is_empty():
		_find_avatars()
	current_file.seek_end()

func _update_timeline(live):
	timeline.max_value = endTime - startTime
	var endDay = str(Time.get_date_dict_from_unix_time(endTime)["day"])
	endLabel.text = convertDay(endDay) + " " + Time.get_time_string_from_unix_time(endTime)
	if live:
		timeline.value = timeline.max_value

func convertDay(day):
	var result
	match day:
		1:
			result = str(day) + "st"
		2:
			result = str(day) + "nd"
		3:
			result = str(day) + "rd"
		_:
			result = str(day) + "th"
	return result

func open_logfile(path):
	if current_file:
		current_file.close()
	current_file = FileAccess.open(path, FileAccess.READ)
	current_file_path = path
	%LogfileLabel.text = "Current logfile: " + current_file_path.get_file()
	last_date_modified = FileAccess.get_modified_time(current_file_path)
	return current_file 

func reload_logfile():
	if not current_file:
		return null
	%LogfileLabel.text = "Current logfile: " + current_file_path.get_file()
	last_date_modified = FileAccess.get_modified_time(current_file_path)
	return current_file 


func scroll_to_last_line():
	var scrollbar: VScrollBar = logview.get_v_scroll_bar()
	scrollbar.value = scrollbar.max_value


func _on_logfile_button_pressed():
	file_dialog.show()


func _on_file_dialog_file_selected(path):
	if open_logfile(path):
		parse_logfile()
		scroll_to_last_line()


func _on_folder_dialog_dir_selected(dir):
	asset_folder_path = dir
	%AssetsLabel.text = "Current base: " + asset_folder_path.get_file()
	generate_shownames()


func _on_link_assets_button_pressed():
	folder_dialog.show()


func _on_refresh_button_pressed():
	if reload_logfile():
		parse_logfile()
		scroll_to_last_line()


func _on_toggle_log_view_toggled(button_pressed):
	logview_window.visible = button_pressed


func _on_toggle_parsed_view_toggled(button_pressed):
	parsed_view_window.visible = button_pressed


func _on_button_toggled(button_pressed):
	%Characters.visible = button_pressed


func _on_timeline_value_changed(value):
	var currentDay = Time.get_date_dict_from_unix_time(startTime)["day"]
	currentLabel.text = convertDay(currentDay) + " " + Time.get_time_string_from_unix_time(timeline.value + startTime)
	for character in characters:
		var locationID = _find_charLocation(character.id, value + startTime)
		if locationID != null and locationID != character.currentLocationID:
			areas.movement(character, true, locationID)

func _find_charLocation(charID, newTime):
	#movements.append([currentCharacter.id, int(fromID), int(toID), time])
	var result = null
	for movement in movements:
		if movement[0] == charID:
			if movement[3] <= newTime:
				result = movement[2]
			else:
				return result
	return result

func _on_next_movement_pressed():
	var newTime = endTime
	for move in movements:
			if move[3] > timeline.value + startTime:
				if move[3] < newTime:
					newTime = move[3]
	timeline.value = newTime - startTime


func _on_prev_step_pressed():
	var newTime = startTime
	if timeline.value != 0:
		for move in range(movements.size()-1, 0, -1):
			if movements[move][3] < timeline.value + startTime:
					if movements[move][3] > newTime:
						newTime = movements[move][3]
	timeline.value = newTime - startTime


func _on_live_pressed():
	timeline.value = endTime


func _on_play_toggled(toggled):
	if toggled:
		playing_backward = false
		playing = true
		playButton.text = "||"
		playbackButton.text = " < "
		playbackButton.button_pressed = false
	else:
		playing = false
		playButton.text = " > "



func _on_backwardplay_toggled(toggled):
	if toggled:
		playing = false
		playing_backward = true
		playbackButton.text = "||"
		playButton.text = " > "
		playButton.button_pressed = false
	else:
		playing_backward = false
		playbackButton.text = " < "


func _on_parsed_view_window_close_requested():
	parsed_view_window.hide()
	%ToggleParsedView.button_pressed = false


func _on_log_view_window_close_requested():
	logview_window.hide()
	%ToggleLogView.button_pressed = false


func _on_map_file_dialog_file_selected(path):
	swapMap.emit(path)


func _on_map_image_pressed():
	map_file_dialog.show()


func _on_zoom_in_pressed():
	zoom.emit(1)


func _on_zoom_out_pressed():
	zoom.emit(-1)


func _on_reset_camera_pressed():
	reset_camera.emit()


func _on_areas_movement_made(_chara: CharacterNode, line_number: int) -> void:
	pass


func _on_map_color_picker_color_changed(color: Color) -> void:
	map_change_color.emit(color)


func _on_save_layout_pressed() -> void:
	layout_file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	layout_file_dialog.title = "Save Layout File"
	layout_file_dialog.ok_button_text = "Save"
	layout_file_dialog.show()


func _on_load_layout_pressed() -> void:
	layout_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	layout_file_dialog.title = "Open Layout File"
	layout_file_dialog.ok_button_text = "Open"
	layout_file_dialog.show()


func _on_layout_file_dialog_file_selected(path: String) -> void:
	if layout_file_dialog.file_mode == FileDialog.FILE_MODE_OPEN_FILE:
		if not FileAccess.file_exists(path):
			return
		var layout_file = FileAccess.open(path, FileAccess.READ)
		var json = JSON.new()
		var error = json.parse(layout_file.get_as_text())
		if error != OK:
			print("Failed to open layout file: %" % path)
			return
		var data = json.data
		areas.load_data(data)
	elif layout_file_dialog.file_mode == FileDialog.FILE_MODE_SAVE_FILE:
		var layout_file = FileAccess.open(path, FileAccess.WRITE)
		var json_string = JSON.stringify(areas.save_data())
		layout_file.store_line(json_string)
