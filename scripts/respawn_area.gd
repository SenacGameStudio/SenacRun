extends Node2D

@export var scene_name = ""

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		call_deferred("load_scene")

func load_scene():
	get_tree().change_scene_to_file("res//scenes/" + scene_name + ".tscn")


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		call_deferred("load_scene")
