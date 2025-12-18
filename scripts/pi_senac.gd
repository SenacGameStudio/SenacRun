extends Node2D

@export var scene_name = ""
@onready var music = $AudioStreamPlayer2D2

func _ready() -> void:
	music.play()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		call_deferred("recarregar_cena")


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		call_deferred("recarregar_cena")

func _on_level_end_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		call_deferred("mudar_cena")


func _on_level_end_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		call_deferred("mudar_cena")


func _on_audio_stream_player_2d_2_finished() -> void:
	music.play()

func recarregar_cena():
	get_tree().reload_current_scene()

func mudar_cena():
	music.stop()
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")