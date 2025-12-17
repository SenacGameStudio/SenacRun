extends Control

@onready var music: AudioStreamPlayer = $AudioStreamPlayer
@onready var timer: Timer = $Timer

func _ready() -> void:
	music.play()
	timer.start()

func _on_timer_timeout() -> void:
	fade_out_music(1.5)

func fade_out_music(duration: float):
	var fade_tween = create_tween()
	
	fade_tween.tween_property(music, "volume_db", -80.0, duration)
	fade_tween.finished.connect(music.stop)
	
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
