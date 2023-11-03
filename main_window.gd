extends Control

@onready var logview: TextEdit = $LogView
@onready var parsed_view: RichTextLabel = $PanelContainer/ParsedView
@onready var file_dialog: FileDialog = $FileDialog
@onready var folder_dialog: FileDialog = $FolderDialog


var asset_folder_path: String

var current_file: FileAccess
var current_file_path: String
var last_date_modified


func _process(delta):
	if current_file_path and last_date_modified != FileAccess.get_modified_time(current_file_path):
		if reload_logfile():
			logview.text = current_file.get_as_text()
			scroll_to_last_line()
			parse_logfile()


func parse_line(line):
	if not line.begins_with("["):
		parsed_view.add_text(line + "\n")
		return
	var is_ooc = false
	if line.begins_with("[OOC]"):
		is_ooc = true
		line = line.substr("[OOC]".length())
	var timestamp = line.substr(0, line.find("]"))
	var message = line.substr(timestamp.length()+1).strip_edges()
	var speaker = message.substr(0, message.find(":")).strip_edges()
	var italics = false
	if speaker.ends_with(" shouts"):
		italics = true
		speaker = speaker.substr(0, speaker.length() - " shouts".length())
	if speaker.ends_with(" has played a song"):
		italics = true
		speaker = speaker.substr(0, speaker.length() - " has played a song".length())
	var showname = speaker.substr(0, message.find("(")).strip_edges()
	if showname != speaker:
		speaker = speaker.substr(showname.length()+1).strip_edges().trim_prefix("(").trim_suffix(")")
	# TODO: parse speaker even in "shouts", "plays music" etc. IC logs
	var speaker_icon = asset_folder_path + "/characters/" + speaker + "/char_icon.png"
#	if speaker == "$":
#		speaker_icon = asset_folder_path + "/evidence/empty.png"
	if FileAccess.file_exists(speaker_icon):
		# TODO: cache this, ideally by using Godot's resource system properly
		var image = Image.load_from_file(speaker_icon)
		var texture = ImageTexture.create_from_image(image)
		# Add image to the bbcode tag stack
		parsed_view.add_image(texture, 24, 24)
	else:
		push_warning("Couldn't find char_icon for %s" % [speaker_icon])
	if italics:
		parsed_view.push_italics()
	parsed_view.add_text(message + "\n")
	if italics:
		parsed_view.pop()


func parse_logfile():
	parsed_view.clear()
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
