extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var anim: AnimatedSprite2D = $AnimacaoInimigo
@onready var detector_terreno: RayCast2D = $DetectorTerreno
@onready var detector_parede: RayCast2D = $DetectorParede
@onready var hurtbox: Area2D = $Hurtbox
@onready var hitbox: Area2D = $Hitbox

enum EstadoInimigo {
	andando,
	parado,
	morrendo
}
@export var direction: int = 1
var estado_inimigo = EstadoInimigo
func _ready() -> void:
	preparar_andando()
	


func _physics_process(delta: float) -> void:
	ativar_gravidade(delta)
	
	match estado_inimigo:
		EstadoInimigo.andando:
			estado_andando(delta)
		EstadoInimigo.parado:
			estado_parado(delta)
		EstadoInimigo.morrendo:
			estado_morrendo(delta)
			
	move_and_slide()

func preparar_morrendo():
	estado_inimigo = EstadoInimigo.morrendo
	velocity = Vector2.ZERO
	hitbox.process_mode = Node.PROCESS_MODE_DISABLED
	anim.play("morrendo")

func preparar_andando():
	estado_inimigo = EstadoInimigo.andando
	anim.play("andando")
	
func preparar_parado():
	estado_inimigo = EstadoInimigo.parado
	anim.play("parado")
	
func estado_andando(_delta):
	velocity.x = direction * SPEED
	if detector_parede.is_colliding():
		direction *= -1
		scale.x *= -1
	if not detector_terreno.is_colliding():
		direction *= -1
		scale.x *= -1
		
func estado_morrendo(_delta):
	pass

func estado_parado(_delta):
	pass

func ativar_gravidade(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
