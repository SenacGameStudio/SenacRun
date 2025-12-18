extends CharacterBody2D


const SPEED = 80.0
const JUMP_VELOCITY = -400.0

@onready var anim: AnimatedSprite2D = $AnimacaoInimigo
@onready var detector_parede: RayCast2D = $DetectorParede
@onready var hurtbox: Area2D = $Hurtbox
@onready var hitbox: Area2D = $Hitbox
@onready var timer: Timer = $Timer

enum State {
	idle,
	hit,
	run,
	jump
}

@export var direction: int = 1
var state_inimigo = State.idle

func _ready() -> void:
	prepara_run()

func _physics_process(delta: float) -> void:
	ativar_gravidade(delta)

	match state_inimigo:
		State.idle:
			idle_state(delta)
		State.run:
			run_state(delta)
		State.jump:
			jump_state(delta)
		State.hit:
			hit_state(delta)

	move_and_slide()

func ativar_gravidade(delta: float):
	if not is_on_floor():
		velocity += get_gravity() * delta

func prepara_idle():
	state_inimigo = State.idle
	anim.play("andando")

func prepara_run():
	state_inimigo = State.run
	anim.play("andando")

func prepara_hit():
	state_inimigo = State.hit
	anim.play("andando")
	velocity = Vector2.ZERO

	hitbox.set_deferred("monitoring", false)
	hurtbox.set_deferred("monitoring", false)

	hitbox.set_collision_mask_value(2, false)
	hurtbox.set_collision_mask_value(2, false)

	$CollisionShape2D.set_deferred("disabled", true)
	timer.start()

func idle_state(_delta):
	pass

func run_state(_delta):
	velocity.x = SPEED * direction

	if detector_parede.is_colliding():
		scale.x *= -1
		direction *= -1


func hit_state(_delta):
	pass

func jump_state(_delta):
	pass


func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		prepara_hit()

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if body.has_method("anima_morto"):
			body.anima_morto()

func _on_timer_timeout() -> void:
	queue_free()
