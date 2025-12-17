extends AnimatedSprite2D

var speed: int = 180
var direction: int

func _physics_process(delta: float) -> void:
	move_local_x(direction * speed * delta)


func _on_timer_timeout() -> void:
	queue_free()
