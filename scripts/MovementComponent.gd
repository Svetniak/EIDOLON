extends Node
class_name MovementComponent

# --- REFERENCES ---
@export var body: CharacterBody2D

# --- PHYSICS VARIABLES ---
@export_group("Movement X")
@export var speed: float = 300.0
@export var acceleration: float = 1200.0
@export var friction: float = 1500.0

@export_group("Gravity Tweaks")
@export var terminal_velocity: float = 700.0
@export var wall_slide_max_speed: float = 150.0

@export_group("Aerial movement")
@export var jump_velocity: float = -400.0
@export var wall_jump_pushback: float = 450.0
@export var wall_slide_gravity: float = 120.0
@export var jump_cut_multiplyer: float = 0.5
@export var coyote_time_duration: float = 0.15

@export_group("Double Jump")
@export var max_air_jumps: int = 2
@export var air_jump_cooldown: float = 0.2

@export_group("Dash")
@export var dash_speed: float = 800.0
@export var dash_duration: float = 0.2
@export var dash_cooldown: float = 0.5
@export var dash_drift: float = 0.6

@export_group("Ajustes de Suavidad")
@export var wall_jump_inertia: float = 300.0
@export var wall_slide_friction: float = 800.0

var current_air_jumps: int = 0
var can_air_jump: bool = true
var is_dashing: bool = false
var can_dash: bool = true
var is_wall_jumping: bool = false
var coyote_timer: float = 0.0

@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") 

func handle_movement(input_dir: float, delta: float):
	# 1. SI ESTAMOS EN DASH, SOLO MOVER Y SALIR
	if is_dashing:
		body.move_and_slide()
		return

	if body.is_on_floor():
		coyote_timer = coyote_time_duration
		current_air_jumps = max_air_jumps
		can_air_jump = true
	else:
		coyote_timer -= delta

	# 2. GRAVEDAD Y WALL SLIDE
	if not body.is_on_floor():
		if body.is_on_wall_only() and body.velocity.y > 0:
			body.velocity.y = move_toward(body.velocity.y, wall_slide_max_speed, delta * wall_slide_friction)
		else:
			body.velocity.y += gravity * 1.5 * delta

		body.velocity.y = min(body.velocity.y, terminal_velocity)
	
	# 3. MOVIMIENTO HORIZONTAL
	if not is_wall_jumping:
		if input_dir:
			body.velocity.x = move_toward(body.velocity.x, input_dir * speed, acceleration * delta)
		else:
			body.velocity.x = move_toward(body.velocity.x, 0, friction * delta)
	else:
		body.velocity.x = move_toward(body.velocity.x, 0, delta * wall_jump_inertia)
	
	# 5. EJECUCIÓN FÍSICA ÚNICA
	body.move_and_slide()
	

func jump():
	if coyote_timer > 0.001:
		print("Coyote antes de saltar: ",coyote_timer)
		body.velocity.y = jump_velocity
		coyote_timer = -1.0
		print("Salto ejecutado: Suelo/Coyote")
	elif current_air_jumps > 0 and can_air_jump:
		air_jump()
		print("Salto ejecutado: Aire")

func handle_jump_cut():
	if body.velocity.y < 0:
		body.velocity.y *= jump_cut_multiplyer

func wall_jump():
	var wall_normal = body.get_wall_normal()
	is_wall_jumping = true 
	body.velocity.y = jump_velocity
	body.velocity.x = wall_normal.x * wall_jump_pushback
	await get_tree().create_timer(0.15).timeout
	is_wall_jumping = false

func air_jump():
	body.velocity.y = jump_velocity
	current_air_jumps -= 1
	_start_air_jump_cooldown()

func _start_air_jump_cooldown():
	can_air_jump = false
	await get_tree().create_timer(air_jump_cooldown).timeout
	can_air_jump = true

func dash(direction: float):
	if not can_dash or is_dashing: return

	var dash_dir = direction if direction != 0 else (1.0 if body.get_node("AnimatedSprite2D").flip_h == false else -1.0)

	is_dashing = true
	can_dash = false

	var original_v = body.velocity.y
	body.velocity.y = 0
	body.velocity.x = dash_dir * dash_speed

	# DURACIÓN DEL DASH (0.2s)
	await get_tree().create_timer(dash_duration).timeout
	
	is_dashing = false
	body.velocity.y = original_v
	body.velocity.x *= dash_drift
	
	# COOLDOWN
	await get_tree().create_timer(dash_cooldown).timeout
	can_dash = true
