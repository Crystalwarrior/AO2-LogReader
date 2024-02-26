extends HBoxContainer

var id
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

#func change_connectionState(state):
	#if state:
		#if charName != null:
			#print(charName + " SET DISCONNECT TO " + str(state))
		#else:
			#if showName != null:
				#print(showName + " SET DISCONNECT TO " + str(state))
	#disconnectState = state
	#get_node("Icon/Disconnect").visible = state
	#if mapChar != null:
		#mapChar.get_child(0).visible = state


func _on_visibility_toggled(toggle):
		mapChar.visible = !toggle
