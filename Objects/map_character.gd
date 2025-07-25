extends Control

@onready var texture_rect = %TextureRect
@onready var dc_state = %DCState

var animation_tween
var current_tracer

var character

signal fade_finished

func fade(from, to, time = 1.0, delay = 0.0):
	if animation_tween:
		animation_tween.stop()
	animation_tween = create_tween()
	animation_tween.tween_property(self, "modulate:a", from, 0.0)
	animation_tween.tween_interval(delay)
	animation_tween.tween_property(self, "modulate:a", to, time)
	fade_finished.emit()
