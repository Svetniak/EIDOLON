extends CharacterBody2D

# --- REFERENCIAS A COMPONENTES ---
@onready var input = $InputComponent
@onready var movement = $MovementComponent
@onready var shoot_comp = $ShootComponent
@onready var sprite = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# 1. LÓGICA DE MOVIMIENTO Y ACCIONES
	if movement.is_dashing:
		movement.handle_movement(input.input_vector.x, delta)
	else:
		movement.handle_movement(input.input_vector.x, delta)

		# JUMP ACTION
		if input.wants_to_jump:
			if is_on_wall_only():
				movement.wall_jump()
			else:
				movement.jump()

		# VJH (Variable Jump Height)
		if input.jump_released:
			movement.handle_jump_cut()

		# DASH
		if input.wants_to_dash:
			movement.dash(input.input_vector.x)

	# 2. DISPARO (Independiente del movimiento)
	if input.wants_to_shoot:
		var dir = Vector2.RIGHT
		if input.input_vector.x < 0:
			dir = Vector2.LEFT
		elif input.input_vector.x > 0:
			dir = Vector2.RIGHT
		else:
			dir = Vector2.LEFT if sprite.flip_h else Vector2.RIGHT

		shoot_comp.shoot(dir)

	# 3. ACTUALIZAR VISUALES
	update_animations()

func update_animations() -> void:
	if input.input_vector.x != 0 and not movement.is_dashing:
		sprite.flip_h = input.input_vector.x < 0

	if movement.is_dashing:
		sprite.play("dash")
		return

	if not is_on_floor():
		if is_on_wall_only():
			sprite.play("on_wall")
		elif input.wants_to_shoot:
			sprite.play("shoot_jump")
		elif velocity.y > 0:
			sprite.play("fall")
		else:
			sprite.play("jump")
		return

	if input.input_vector.x != 0:
		if input.wants_to_shoot:
			sprite.play("shoot_run")
		else:
			sprite.play("walk")
	else:
		if input.wants_to_shoot:
			sprite.play("shoot_stand")
		else:
			sprite.play("idle_1")
