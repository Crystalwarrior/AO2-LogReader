extends HBoxContainer
class_name CharacterNode

var id
var aoid
var charfolder
var names = []
var current_name = ""
var color
var mapChar
var avatar
var disconnected
var currentLocationID = null
var is_visible = true

signal toggled_focus(toggle: bool)
signal toggled_visible(toggle: bool)

func add_name(newName):
	if !names.has(newName):
		names.append(newName)
		%Names.add_item(newName)
	if !%Namelock.button_pressed:
		var idx = %Names.item_count-1
		%Names.select(idx)
		_on_names_item_selected(idx)
	update_mapchar()

func set_color(newColor):
	color = newColor
	%Icon.self_modulate = color

func set_avatar(texture):
	%Icon.self_modulate = Color.WHITE
	%Icon.texture = texture
	color = get_color_from_texture(%Icon.texture)
	if mapChar:
		mapChar.self_modulate = Color.WHITE
		mapChar.texture_rect.texture = texture

func set_aoid(to_aoid):
	aoid = to_aoid
	%ClientID.text = "[%s]" % ["?" if aoid == null else aoid]
	update_mapchar()

func get_color_from_texture(tex: Texture) -> Color:
	var color = Vector3.ZERO
	var texture_size = tex.get_size()
	var image = tex.get_image()
	
	for y in range(0, texture_size.y):
		for x in range(0, texture_size.x):
			var pixel = image.get_pixel(x, y)
			color += Vector3(pixel.r, pixel.g, pixel.b)
			
	color /= texture_size.x * texture_size.y
	return Color(color.x, color.y, color.z)

func _on_visibility_toggled(toggle):
	is_visible = toggle
	if mapChar:
		mapChar.visible = toggle
	toggled_visible.emit(toggle)

func set_disconnect_state(state):
	disconnected = state
	%DCState.visible = disconnected
	if mapChar:
		mapChar.dc_state.visible = false

func update_mapchar():
	if not mapChar:
		return
	mapChar.name = "[%s] %s" % ["?" if aoid == null else aoid, current_name]
	mapChar.tooltip_text = mapChar.name

func _on_names_item_selected(index: int) -> void:
	current_name = %Names.get_item_text(%Names.selected)
	update_mapchar()


func _on_focus_toggled(toggled_on: bool) -> void:
	toggled_focus.emit(toggled_on)
