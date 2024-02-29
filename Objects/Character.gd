extends HBoxContainer

var InvisButton

var id
var aoid
var charfolder
var names = []
var color
var mapChar
var avatar
var disconnected
var currentLocationID = null

func _ready():
	InvisButton = get_parent().get_parent().get_parent().get_node("HBoxContainer/Hide invis")

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

func set_disconnect_state(state):
	disconnected = state
	get_node("Icon/Disconnect").visible = state
	if mapChar != null:
		mapChar.get_child(0).visible = state


func _on_visibility_toggled(toggle):
	if mapChar:
		mapChar.visible = !toggle
	if InvisButton.button_pressed:
		self.visible = false
