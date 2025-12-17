extends Control

@onready var music_player = $Music

func _ready() -> void:
	music_player.play()
	$VBoxContainer/StartButton.grab_focus()


func _on_sair_button_pressed() -> void:
	music_player.stop()
	get_tree().quit()

func _on_creditos_button_pressed() -> void:
	music_player.stop()
	get_tree().change_scene_to_file("res://scenes/creditos.tscn")

func _on_start_button_pressed() -> void:
	music_player.stop()
	get_tree().change_scene_to_file("res://scenes/pi_senac.tscn")
