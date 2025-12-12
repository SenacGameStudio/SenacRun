extends  CharacterBody2D

@onready var animacao_player: AnimatedSprite2D = $animacao_player
const MAX_JUMP = 2
const SPEED = 260.0
const JUMP_VELOCITY = -400.0 
const ACELERACAO = 200
const DESACELERACAO = 450
var JUMP_COUNT = 2
var direcao = 0

enum EstadoPlayer{
	parado,
	atirando,
	andando,
	pulando,
	morto,
}

var estado_atual: EstadoPlayer
var direction = 0

func _ready() -> void:
	prepara_parado()
	
func _physics_process(delta: float) -> void:
	match estado_atual:
		EstadoPlayer.parado:
			parado(delta)
		
		EstadoPlayer.andando:
			andando(delta)
			
		EstadoPlayer.pulando:
			pulando(delta)
		EstadoPlayer.atirando:
			atirando(delta)
			
		EstadoPlayer.morto:
			morto(delta)
			
	move_and_slide()
	
	
func ativar_gravidade (delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
		
func mover(delta):
	atualizar_animacao()
	if direction:
		velocity.x = move_toward(velocity.x,direction * SPEED,ACELERACAO * delta)
	else:
		velocity.x = move_toward(velocity.x,0,DESACELERACAO * delta)

func atualizar_animacao():
	direction = Input.get_axis("ui_left", "ui_right")
	if direction < 0:
		animacao_player.flip_h = true
	elif direction > 0:
		animacao_player.flip_h = false
		
func pode_pular():
	if JUMP_COUNT < MAX_JUMP:
		return true
	else:
		return false
		
func andando(delta):
	ativar_gravidade(delta)
	mover(delta)
	if velocity.x == 0:
		prepara_parado()
		return
		
	if Input.is_action_just_pressed("pulo"):
		prepara_pulando()
		return
		
	if not is_on_floor():
		JUMP_COUNT += 1
		return
	
	if Input.is_action_just_pressed("atirar"):
		prepara_atirando()
		return
		
func pulando(delta):
	ativar_gravidade(delta)
	mover(delta)
	
	if Input.is_action_just_pressed("pulo") && pode_pular():
		prepara_pulando()
		return
		
	
		
func parado(delta):
	ativar_gravidade(delta)
	mover(delta)
	
	if velocity.x != 0 :
		prepara_andando()
		return
		
	if Input.is_action_just_pressed("pulo"):
		prepara_pulando()
		return
	
	if Input.is_action_just_released("atirar"):
		prepara_atirando()
		return

func atirando(delta):
	ativar_gravidade(delta)
	mover(delta)
	
	if Input.is_action_just_pressed("atirar"):
		prepara_atirando()
		return
		
	if Input.is_action_just_released("parado"):
		prepara_parado()
		return
		
func morto (_delta):
	prepara_morto()
	
		
func prepara_pulando():
	estado_atual = EstadoPlayer.pulando
	animacao_player.play("pulando")
	velocity.y = JUMP_VELOCITY
	JUMP_COUNT += 1

func prepara_andando():
	estado_atual = EstadoPlayer.andando
	animacao_player.play("andando")
	
func prepara_parado():
	estado_atual = EstadoPlayer.parado
	animacao_player.play("parado")

func prepara_atirando():
	estado_atual = EstadoPlayer.atirando
	animacao_player.play("atirando")
	
func prepara_morto():
	estado_atual = EstadoPlayer.morto
	animacao_player.play("morto")
	velocity = Vector2.ZERO
