extends CharacterBody2D

const SPEED = 80.0
const JUMP_VELOCITY = -400.0

@onready var anim: AnimatedSprite2D = $AnimacaoInimigo
@onready var detector_parede: RayCast2D = $DetectorParede
@onready var detector_terreno: RayCast2D = $DetectorTerreno
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
    # Garante que a escala inicial condiz com a direção exportada
    if direction == -1:
        scale.x = -1
    prepara_run()

func _physics_process(delta: float) -> void:
    # Gravidade deve rodar para todos os estados, exceto talvez no 'hit' 
    # se você quiser que ele fique parado no ar.
    if state_inimigo != State.hit:
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

# --- Funções de Preparação ---

func prepara_idle():
    state_inimigo = State.idle
    velocity.x = 0
    anim.play("parado") # Geralmente idle usa animação parado

func prepara_run():
    state_inimigo = State.run
    anim.play("andando")

func prepara_hit():
    if state_inimigo == State.hit: return # Evita repetir o processo
    
    state_inimigo = State.hit
    anim.play("parado")
    velocity = Vector2.ZERO

    # Desabilita colisões e áreas para evitar múltiplos hits
    hitbox.set_deferred("monitoring", false)
    hitbox.set_deferred("monitorable", false)
    hurtbox.set_deferred("monitoring", false)
    hurtbox.set_deferred("monitorable", false)

    $CollisionShape2D.set_deferred("disabled", true)
    timer.start()

# --- Funções de Estado ---

func idle_state(_delta):
    pass
	
func run_state(_delta):
    velocity.x = SPEED * direction

    # Verificamos se há colisão
    # Adicionamos um pequeno delay lógico ou apenas checamos a colisão
    if detector_parede.is_colliding() or not detector_terreno.is_colliding():
        inverter_direcao()

func hit_state(_delta):
    # O inimigo fica parado até o Timer do queue_free terminar
    velocity = Vector2.ZERO

func jump_state(_delta):
    pass

# --- Funções Auxiliares ---


func inverter_direcao():
    # Inverte a variável de direção
    direction *= -1
    
    # EM VEZ DE scale.x *= -1 no corpo todo, fazemos:
    anim.flip_h = (direction == -1) # Inverte apenas o desenho
    
    # Inverte a posição dos RayCasts manualmente para não bugarem
    detector_parede.target_position.x *= -1
    
    # O Detector de terreno geralmente fica deslocado para frente. 
    # Precisamos inverter a posição X dele também:
    detector_terreno.position.x *= -1

# --- Sinais ---

func _on_hurtbox_area_entered(area: Area2D) -> void:
    # Ajustado para Area2D se o Player usar uma área de ataque
    if area.is_in_group("PlayerAtaque"):
        prepara_hit()

func _on_hitbox_body_entered(body: Node2D) -> void:
    if body.is_in_group("Player"):
        if body.has_method("anima_morto"):
            body.anima_morto()

func _on_timer_timeout() -> void:
    queue_free()