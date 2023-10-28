extends Control

@onready var logview: TextEdit = $LogView #Contains the TextEdit node where the log text and view is contained
@onready var parsed_view: RichTextLabel = $PanelContainer/ParsedView #Contains the RichTextLabel node where parsed view is contained (the one with the icon and emojis and such)
@onready var file_dialog: FileDialog = $FileDialog #A node that allows you to choose files or directories from a file system, at the start it is not shown ((For choosing the log file))
@onready var folder_dialog: FileDialog = $FolderDialog #A node that allows you to choose files or directories from a file system, at the start it is not shown ((For the AO assetts))


var asset_folder_path: String #variable that contains the file explorer path to the AO2 asset folder (base folder) in a string of text

var current_file: FileAccess
var current_file_path: String #variable that contains the file explorer path to the log file that is being read in a string
var last_date_modified


func _process(delta):
#Each frame, if the current file path and last date modified are not equal to the previous modified time of the current file in the path
	if current_file_path and last_date_modified != FileAccess.get_modified_time(current_file_path):
		reload_logfile() #Reload the current log file in the file path and do the open_logfile function
		logview.text = current_file.get_as_text()
		scroll_to_last_line() #Scrolls to the last line using a scrollbar
		parse_logfile()


func parse_line(line):
	var speaker = line.substr(0, line.find(":")).strip_edges()
	var showname = speaker.substr(0, line.find("(")).strip_edges()
	if showname != speaker:
		speaker = speaker.substr(showname.length()+1).strip_edges().trim_prefix("(").trim_suffix(")")
	# TODO: parse speaker even in "shouts", "plays music" etc. IC logs
	var speaker_icon = asset_folder_path + "/characters/" + speaker + "/char_icon.png"
	if FileAccess.file_exists(speaker_icon):
		# TODO: cache this, ideally by using Godot's resource system properly
		var image = Image.load_from_file(speaker_icon)
		var texture = ImageTexture.create_from_image(image)
		# Add image to the bbcode tag stack
		parsed_view.add_image(texture, 24, 24)
	else:
		push_warning("Couldn't find char_icon for %s" % [speaker_icon])
	parsed_view.add_text(line + "\n")


func parse_logfile():
	parsed_view.clear()
	var lines = logview.text.split("\n")
	for line in lines:
		if not line.begins_with("["):
			continue
		# TODO: parse movement etc.
		if line.begins_with("[OOC]"):
			continue
		var timestamp = line.substr(0, line.find("]"))
		var message = line.substr(timestamp.length()+1).strip_edges()
		parse_line(message)


func open_logfile(path):
	if current_file: #If the file is currently opened, then close it
		current_file.close()
	current_file = FileAccess.open(path, FileAccess.READ) #Open the file on the path and start reading it
	current_file_path = path
	$LogfileLabel.text = "Current logfile: " + current_file_path #Add the path to the log file to the LogfileLabel text component 
	last_date_modified = FileAccess.get_modified_time(path) #Get the current time of when the file on the path was last modified and put that value in the last_time_modified variable
	return current_file #Return the variable containing the current value of the current_file


func reload_logfile():
	return open_logfile(current_file_path) #Returns the function to open the log file in the current file path


func scroll_to_last_line(): 
#Adds a scrollbar to the logview window that can be moved
	var scrollbar: VScrollBar = logview.get_v_scroll_bar()
	scrollbar.value = scrollbar.max_value


func _on_logfile_button_pressed(): 
#When the [Open Logfile] button is pressed it shows a window to choose a file from your PC
	file_dialog.show()


func _on_file_dialog_file_selected(path):
#When a file in the file_dialog window is choosen, it will get its file path to the file and open it
#It will then if determined that the file in the path can be opened,
	if open_logfile(path):
		logview.text = current_file.get_as_text()
		scroll_to_last_line()


func _on_folder_dialog_dir_selected(dir):
#When a folder its selected it sets its path to the variable asset_folder_path
#It thens makes the text of the AssetsLable node into "current base" plus the path of the asset folder
	asset_folder_path = dir
	$AssetsLabel.text = "Current base: " + asset_folder_path


func _on_link_assets_button_pressed():
#When the [Link Assets] button is pressed it shows a window to choose a folder from your PC
	folder_dialog.show()
