extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -300.0


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()


func teleport(area: Area2D) -> void:
	for portal in get_tree().get_nodes_in_group("portal"):
		if portal != area and portal.portal_id == area.portal_id:
			if not portal.portal_is_locked:
				area.lock_portal()
				global_position = portal.global_position
		
		
		

func _on_portal_area_entered(area: Area2D) -> void:
	if area.is_in_group("portal") and not area.portal_is_locked:
		teleport(area)
