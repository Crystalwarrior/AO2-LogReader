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
	color = get_color_from_texture($Icon.texture)
	if mapChar:
		mapChar.self_modulate = Color.WHITE
		mapChar.texture = texture

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
	if mapChar:
		mapChar.visible = !toggle
