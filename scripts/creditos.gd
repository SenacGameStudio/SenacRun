extends ScrollContainer

@onready var content_container: MarginContainer = $MarginContainer
@onready var text_node: RichTextLabel = $MarginContainer/RichTextLabel
@onready var music_player: AudioStreamPlayer = $MusicaCreditos

@export_range(1.0, 180.0, 0.1) var tempo_rolagem: float = 30.0
@export_range(0.0, 500.0, 1.0) var espaco_extra_final: float = 100.0

var scroll_max_value: float = 0.0

func _ready() -> void:
	await get_tree().process_frame

	var viewport_height = size.y
	var text_height = content_container.size.y
   
	scroll_max_value = text_height + viewport_height + espaco_extra_final

	content_container.add_theme_constant_override("margin_top", viewport_height)
	content_container.add_theme_constant_override("margin_bottom", viewport_height)
	
	music_player.play()
	var tween = create_tween()
	
	tween.tween_property(self, "scroll_vertical", text_height + viewport_height + espaco_extra_final, tempo_rolagem)
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_LINEAR)
	
	tween.finished.connect(_on_credits_finished)
	tween.play()

func _on_credits_finished():
	fade_out_music(1.5)

func fade_out_music(duration: float):
	var fade_tween = create_tween()
	
	fade_tween.tween_property(music_player, "volume_db", -80.0, duration)
	fade_tween.finished.connect(music_player.stop)
	
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
