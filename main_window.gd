extends Control

@onready var logview: TextEdit = $LogView
@onready var parsed_view: RichTextLabel = $PanelContainer/ParsedView
@onready var file_dialog: FileDialog = $FileDialog
@onready var folder_dialog: FileDialog = $FolderDialog

signal movement(char, from, fromID, to, toID)

signal placeChar(char, icon, to, toID)

var characterNode = preload("res://Objects/Character.tscn")

var asset_folder_path: String

var current_file: FileAccess
var current_file_path: String
var last_date_modified

var hostname: String


#{"showname": "charfolder"}
var shownames: Dictionary = {}

func _process(delta):
	if current_file_path and last_date_modified != FileAccess.get_modified_time(current_file_path):
		if reload_logfile():
			logview.text = current_file.get_as_text()
			scroll_to_last_line()
			parse_logfile()


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
					var config = FileAccess.open(ini_path, FileAccess.READ)
					print("Found .ini file in folder: " + file_name)
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
									print("Showname '" + showname + "' now associated with charfolder " + file_name)
			file_name = dir.get_next()


func parse_line(line):
	if not line.begins_with("[") or not line.contains("GMT]"):
		parsed_view.add_text(line + "\n")
		return
	var is_ooc = false
	if line.begins_with("[OOC]"):
		is_ooc = true
		line = line.substr("[OOC]".length())
	var timestamp = line.substr(0, line.find("]"))
	line = line.substr(timestamp.length()+1)
	var message = line.substr(line.find(":")+1).strip_edges()
	var speaker = line.substr(0, line.find(":")).strip_edges()

	var character = find_character(line)

#	if !is_ooc: 
#
#		if charName != hostname and hostname != "":	
#			var found = false
#			for char in %CharacterList.get_children():
#				if char.name == charName:
#					found = true
#			if found == false and line.find("[") != -1:
#				create_character(charName, line)


		
	var italics = false
	if is_ooc:
		if not hostname and (message.begins_with("===") or message.begins_with("Changed to")) and speaker != "[Global log]":
			hostname = speaker
		if speaker == hostname and line.find("moves from") != -1:
#			var character = line.split("]")[1].lstrip(" ").split("moves from")[0].rstrip(" ")
			var from = line.split("] ")[2].split(" to")[0]
			var fromID = line.split("] ")[1].split("[")[1]
			var to = line.split("] ")[3].rsplit(".")[0]
			var toID = line.split("] ")[2].split("[")[1]
			emit_signal("movement", character, from, fromID, to, toID)
	else:
		var actions = ["shouts", "has "]
		for action in actions:
			if speaker.find(action) > -1:
				italics = true
				speaker = speaker.substr(0, speaker.find(action))
				break

		var showname = speaker.substr(0, speaker.find("(")).strip_edges()
		var charfolder = showname
		if showname != speaker:
			charfolder = speaker.substr(showname.length()+1).strip_edges().trim_prefix("(").trim_suffix(")")

		if charfolder in shownames:
			charfolder = shownames[charfolder]
		if charfolder:
			var texture = get_speakerIcon(charfolder)
			if texture is ImageTexture:
					# Add image to the bbcode tag stack
				parsed_view.add_image(texture, 24, 24)
			else:
				push_warning("Couldn't find char_icon for %s (%s)" % [asset_folder_path + "/characters/" + charfolder + "/char_icon.png", message])
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
	parsed_view.add_text(message + "\n")
	if italics:
		parsed_view.pop()

func create_character(charfolder, showName, AOID, line):
# PUT CHARACTER INTO THE LIST
	var newChar = characterNode.instantiate()
	newChar.name = charfolder
	newChar.charName = charfolder
	newChar.get_node("Name").text = charfolder
	if AOID != null:
		newChar.AOID = AOID
	if showName != null:
		newChar.showName = showName
	var icon = get_speakerIcon(charfolder)
	if icon is ImageTexture:
		newChar.get_node("Icon").texture = icon
	%CharacterList.add_child(newChar)

#PLACE CHARACTER ON THE MAP
	# FIND AREANAME AND AREAID
	var areaName = null
	var areaID = -1
	if line.find(": }}}[") != -1:
		areaID = line.split(": }}}[")[1].split("]")[0]
	if line.find("moves from") != -1:
		areaName = line.split("] ")[3].rsplit(".")[0]
		areaID = line.split("] ")[2].split("[")[1]
	if line.find("enters from") != -1:
		return

	# EMIT SIGNAL TO AREAS
	if areaID != "-1":
		emit_signal("placeChar", charfolder, icon, areaName, areaID)

	return newChar

func find_character(line):
	var speaker
	var charName
	var showName
	var AOID = null
	var moveline = false
	# FINDING AOID (ID in AO, different from ID used in this program) 
	# AND THE FULL NAME (MEANING SHOWNAME AND CHARACTERNAME TOGETHER)
	if line.find("moves from") != -1:
		speaker = line.split("]")[1].lstrip(" ").split("moves from")[0].rstrip(" ")
		AOID = int(line.substr(line.find("[")+1, line.find("]")-line.find("[")-1))
		moveline = true
	if line.find("enters from") != -1:
		speaker = line.split("]")[1].lstrip(" ").split("enters from")[0].rstrip(" ")
		AOID = int(line.substr(line.find("[")+1, line.find("]")-line.find("[")-1))
		moveline = true
	if line.find(": }}}[") != -1:
		speaker = line.split(":")[0].strip_edges()

	if speaker == null:
		return null

	# IF THERE IS <SHOWNAME>(CHARNAME) STRIP OUT THE SHOWNAME
	var showname = speaker.substr(0, speaker.find("(")).strip_edges()
	var charfolder = showname
	if showname != speaker:
		charfolder = speaker.substr(showname.length()+1).strip_edges().trim_prefix("(").trim_suffix(")")

	if charfolder in shownames:
		charfolder = shownames[charfolder]
	for char in %CharacterList.get_children():
		if char.charName == charName:
			if showname != null:
				if char.showName != showname:
					char.showName = showname
			return char
		if AOID != null and char.AOID == AOID:
			return char
		if showname != null and char.showName == showname:
			return char

	return create_character(charfolder, showname, AOID, line)

func get_speakerIcon(charfolder):
	var speaker_icon = asset_folder_path + "/characters/" + charfolder + "/char_icon.png"
	if FileAccess.file_exists(speaker_icon):
		# TODO: cache this, ideally by using Godot's resource system properly
		var image = Image.load_from_file(speaker_icon)
		return ImageTexture.create_from_image(image)
	else:
		return null

func parse_logfile():
	parsed_view.clear()
	hostname = ""
	var lines = logview.text.split("\n")
	for line in lines:
		parse_line(line)


func open_logfile(path):
	if current_file:
		current_file.close()
	current_file = FileAccess.open(path, FileAccess.READ)
	current_file_path = path
	$LogfileLabel.text = "Current logfile: " + current_file_path
	last_date_modified = FileAccess.get_modified_time(path)
	return current_file


func reload_logfile():
	return open_logfile(current_file_path)


func scroll_to_last_line():
	var scrollbar: VScrollBar = logview.get_v_scroll_bar()
	scrollbar.value = scrollbar.max_value


func _on_logfile_button_pressed():
	file_dialog.show()


func _on_file_dialog_file_selected(path):
	if open_logfile(path):
		logview.text = current_file.get_as_text()
		scroll_to_last_line()
		parse_logfile()


func _on_folder_dialog_dir_selected(dir):
	asset_folder_path = dir
	$AssetsLabel.text = "Current base: " + asset_folder_path
	generate_shownames()


func _on_link_assets_button_pressed():
	folder_dialog.show()


func _on_refresh_button_pressed():
	if reload_logfile():
		logview.text = current_file.get_as_text()
		scroll_to_last_line()
		parse_logfile()


func _on_toggle_log_view_toggled(button_pressed):
	logview.visible = button_pressed


func _on_toggle_parsed_view_toggled(button_pressed):
	$PanelContainer.visible = button_pressed


func _on_button_toggled(button_pressed):
	%Characters.visible = button_pressed
