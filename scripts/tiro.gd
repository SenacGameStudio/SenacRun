extends AnimatedSprite2D

@onready var timer: Timer = $Timer

var direction: int = 1
var speed: int = 600

func _physics_process(delta):
	move_local_x(direction * speed * delta)

func _on_timer_timeout() -> void:
	queue_free()
