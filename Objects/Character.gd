extends HBoxContainer
class_name CharacterNode

var id
var charfolder
var names = []
var color
var mapChar
var avatar
var disconnected
var currentLocationID = null

func add_name(newName):
	if !names.has(newName):
		names.append(newName)
		$Names.add_item(newName)
	if !$Namelock.button_pressed:
		$Names.select($Names.item_count-1)

func set_color(newColor):
	color = newColor
	$Icon.self_modulate = color

func set_avatar(texture):
	$Icon.self_modulate = Color.WHITE
	$Icon.texture = texture
	if mapChar:
		mapChar.self_modulate = Color.WHITE
		mapChar.texture = texture


func _on_visibility_toggled(toggle):
	if mapChar:
		mapChar.visible = !toggle
