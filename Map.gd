extends Sprite2D


func load_image(path):
	if FileAccess.file_exists(path):
		# TODO: cache this, ideally by using Godot's resource system properly
		var image = Image.load_from_file(path)
		return ImageTexture.create_from_image(image)
	else:
		return null


func _on_main_window_swap_map(path):
	texture = load_image(path)
