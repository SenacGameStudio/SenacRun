extends CharacterBody2D

const tiro = preload("res://entidades/tiro.tscn")
@onready var mira: Marker2D = $Mira
# Inicializamos com a posição original para referência
@onready var mira_x_original: float = $Mira.position.x

@onready var anima: AnimatedSprite2D = $animacao_player
@onready var hitbox: Area2D = $Hitbox
@onready var respawn_timer: Timer = $Timer

const BASE_SPEED: float = 180.0
const SPRINT_SPEED: float = 350

const JUMP_VELOCITY: float = -400.0
const MAX_JUMP: int = 2

const DEATH_JUMP_VELOCITY: float = -250.0
const DEATH_FALL_GRAVITY: float = 15.0
const DEATH_SCALE_TARGET: float = 5.0 # Reduzi para 5, pois 100 cobriria a tela toda
const DEATH_EFFECT_DURATION: float = 2.0 # Reduzi para o respawn ser mais ágil

var death_timer_started: bool = false
var death_gravity_active: bool = false

var direction: float = 0
var jump_count: int = 0
var acceleration: float = 1200 # Aumentado para resposta mais rápida
var deceleration: float = 1200
var max_speed: float = BASE_SPEED

enum State {idle, jump, run, fall, ground, hit, shoot}

var state_player: State = State.idle

func _ready() -> void:
	anima_parado()

func _physics_process(delta: float) -> void:
	# Se estiver morto, a lógica é diferente
	if state_player == State.hit:
		estado_morto(delta)
		move_and_slide()
		return

	match state_player:
		State.idle:
			estado_parado(delta)
		State.fall:
			estado_caindo(delta)
		State.run:
			estado_correndo(delta)
		State.jump:
			estado_pulando(delta)
		State.shoot:
			estado_atirando(delta)

	move_and_slide()

# --- Funções de Preparação de Animação/Transição ---

func anima_parado():
	state_player = State.idle
	anima.play("idle")
	anima.speed_scale = 1.0

func anima_correndo():
	state_player = State.run
	anima.play("run")

func anima_pulando():
	state_player = State.jump
	anima.play("jump")
	velocity.y = JUMP_VELOCITY
	jump_count += 1

func anima_caindo():
	state_player = State.fall
	anima.play("idle")

func anima_atirando():
	state_player = State.shoot
	anima.play("shot")
	atirar() # Chama a função de spawnar o projétil

func anima_morto():
	if state_player == State.hit: return

	state_player = State.hit
	anima.z_index = 100
	anima.play("hit")
    
    # Desabilita colisões corretamente
	hitbox.set_deferred("monitoring", false)
	hitbox.set_deferred("monitorable", false)
	$CollisionShape2D.set_deferred("disabled", true)
    
	velocity = Vector2(0, DEATH_JUMP_VELOCITY)
	death_gravity_active = true
	death_timer_started = true
	respawn_timer.start(DEATH_EFFECT_DURATION)

# --- Funções de Estado ---

func estado_parado(delta):
	ativar_gravidade(delta)
	mover(delta)

	if velocity.x != 0:
		anima_correndo()
	elif not is_on_floor():
		anima_caindo()
	elif Input.is_action_just_pressed("pulo"):
		anima_pulando()
	elif Input.is_action_just_pressed("atirar"):
		anima_atirando()

func estado_correndo(delta):
	ativar_gravidade(delta)
	mover(delta)

	# Ajuste da velocidade da animação conforme a velocidade real
	anima.speed_scale = clamp(abs(velocity.x) / BASE_SPEED, 1.0, 1.5)

	if velocity.x == 0:
		anima_parado()
	elif not is_on_floor():
		anima_caindo()
	elif Input.is_action_just_pressed("pulo"):
		anima_pulando()
	elif Input.is_action_just_pressed("atirar"):
		anima_atirando()

func estado_atirando(delta):
	ativar_gravidade(delta)
	mover(delta)
    
	# Se a animação de tiro acabar, volta para o estado correto
	if not anima.is_playing() or Input.is_action_just_released("atirar"):
		if is_on_floor():
			state_player = State.idle if velocity.x == 0 else State.run
		else:
			state_player = State.fall

func estado_pulando(delta):
	ativar_gravidade(delta)
	mover(delta)

	# Pulo variável (soltar botão faz cair mais rápido)
	if Input.is_action_just_released("pulo") and velocity.y < 0:
		velocity.y *= 0.5

	if velocity.y > 0:
		anima_caindo()
    
	# Permite pulo duplo no ar
	if Input.is_action_just_pressed("pulo") and can_jump():
		anima_pulando()

func estado_caindo(delta):
	ativar_gravidade(delta)
	mover(delta)

	if is_on_floor():
		jump_count = 0
		if velocity.x == 0: anima_parado()
		else: anima_correndo()
    
	if Input.is_action_just_pressed("pulo") and can_jump():
		anima_pulando()

func estado_morto(_delta):
	# Gravidade customizada da morte
	velocity.y += DEATH_FALL_GRAVITY
    
	if death_timer_started:
		var progress = 1.0 - (respawn_timer.time_left / DEATH_EFFECT_DURATION)
		var current_scale = lerp(1.0, DEATH_SCALE_TARGET, progress)
		scale = Vector2(current_scale, current_scale)

# --- Funções Auxiliares ---

func mover(delta):
	atualizar_direcao()
	max_speed = SPRINT_SPEED if Input.is_action_pressed("correr") else BASE_SPEED

	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * max_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration * delta)

func ativar_gravidade(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta

func atualizar_direcao():
	direction = Input.get_axis("esquerda", "direita")
	if direction != 0:
		anima.flip_h = (direction < 0)
		# Posiciona a mira para o lado correto
		mira.position.x = mira_x_original * direction

func can_jump():
	return jump_count < MAX_JUMP

func atirar():
	var tiro_instance = tiro.instantiate()
	# Define a direção do tiro baseada no flip da sprite
	tiro_instance.direction = -1 if anima.flip_h else 1
	tiro_instance.global_position = mira.global_position
	get_parent().add_child(tiro_instance)

# --- Sinais ---

func _on_timer_timeout() -> void:
	get_tree().reload_current_scene()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Hurtbox"):
		# Se cair em cima do inimigo, pula. Se bater de lado, morre.
		if velocity.y > 0 and global_position.y < area.global_position.y:
			area.get_parent().prepara_hit()
			velocity.y = JUMP_VELOCITY * 0.6
			jump_count = 1 # Reseta para permitir mais um pulo no ar
		else:
			anima_morto()