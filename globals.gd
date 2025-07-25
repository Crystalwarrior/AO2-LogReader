extends Node

var characters = []
var focused_characters = []

func get_visible_areas():
	var visible_areas = []
	for focus_chara in Globals.focused_characters:
		visible_areas.append(focus_chara.currentLocationID)
	return visible_areas


func update_visible_characters(visible_areas):
	var focus_mode = not Globals.focused_characters.is_empty()
	for other_chara in Globals.characters:
		if other_chara.mapChar and other_chara.is_visible:
			other_chara.mapChar.visible = not focus_mode or other_chara.currentLocationID in visible_areas
