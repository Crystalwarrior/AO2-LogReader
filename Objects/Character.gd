extends HBoxContainer

var id
var names = []
var color
var mapChar
var disconnectState

func add_name(newName):
	if !names.has(newName):
		names.append(newName)
		$Names.add_item(newName)

func set_icon():
	pass

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
