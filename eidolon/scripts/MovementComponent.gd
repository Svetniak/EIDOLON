extends Node
class_name MovementComponent

# --- ESTADOS ---
enum State { GROUNDED, AIRBORNE, DASHING, WALL_ACTION }
var current_state: State = State.GROUNDED

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
@export var jump_buffer_time: float = 0.1
@export var apex_gravity_multiplier: float = 0.5
@export var apex_threshold: float = 50.0
@export var air_acceleration: float = 600.0
@export var air_friction: float = 300.0

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

# --- INTERNAL VARIABLES ---
var current_air_jumps: int = 0
var can_air_jump: bool = true
var is_dashing: bool = false
var can_dash: bool = true
var is_wall_jumping: bool = false
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0

@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# --- CORE LOOP ---

func handle_movement(input_dir: float, delta: float):
	update_state_machine()

	match current_state:
		State.GROUNDED:
			_process_grounded_state(input_dir, delta)
		State.AIRBORNE:
			_process_airborne_state(input_dir, delta)
		State.WALL_ACTION:
			_process_wall_state(input_dir, delta)
		State.DASHING:
			pass

	body.move_and_slide()

func update_state_machine():
	if is_dashing:
		current_state = State.DASHING
		return

	if body.is_on_floor():
		current_state = State.GROUNDED
	elif body.is_on_wall_only():
		current_state = State.WALL_ACTION
	else:
		current_state = State.AIRBORNE

# --- STATE PROCESSORS ---

func _process_grounded_state(input_dir: float, delta: float):
	current_air_jumps = max_air_jumps
	can_air_jump = true
	coyote_timer = coyote_time_duration

	if jump_buffer_timer > 0:
		_execute_jump()

	apply_horizontal_movement(input_dir, acceleration, friction, delta)

func _process_airborne_state(input_dir: float, delta: float):
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta
	coyote_timer -= delta

	# Lógica de Gravedad con Apex Modifier
	var final_gravity = gravity * 1.5
	if abs(body.velocity.y) < apex_threshold:
		final_gravity *= apex_gravity_multiplier
	
	body.velocity.y += final_gravity * delta
	body.velocity.y = min(body.velocity.y, terminal_velocity)

	if not is_wall_jumping:
		apply_horizontal_movement(input_dir, air_acceleration, air_friction, delta)
	else:
		body.velocity.x = move_toward(body.velocity.x, 0, delta * wall_jump_inertia)

func _process_wall_state(input_dir: float, delta: float):
	if body.velocity.y > 0:
		body.velocity.y = move_toward(body.velocity.y, wall_slide_max_speed, delta * wall_slide_friction)
	else:
		body.velocity.y += gravity * 1.5 * delta
	
	current_air_jumps = max_air_jumps
	apply_horizontal_movement(input_dir, acceleration, friction, delta)

# --- HELPERS ---

func apply_horizontal_movement(input_dir: float, acc: float, frc: float, delta: float):
	if input_dir:
		body.velocity.x = move_toward(body.velocity.x, input_dir * speed, acc * delta)
	else:
		body.velocity.x = move_toward(body.velocity.x, 0, frc * delta)

# --- ACTIONS ---

func jump():
	if current_state == State.GROUNDED or coyote_timer > 0:
		_execute_jump()
	elif current_state == State.AIRBORNE:
		if current_air_jumps > 0 and can_air_jump:
			air_jump()
		else:
			jump_buffer_timer = jump_buffer_time

func _execute_jump():
	body.velocity.y = jump_velocity
	coyote_timer = -1.0
	jump_buffer_timer = 0.0

func air_jump():
	body.velocity.y = jump_velocity
	current_air_jumps -= 1
	_start_air_jump_cooldown()

func _start_air_jump_cooldown():
	can_air_jump = false
	await get_tree().create_timer(air_jump_cooldown).timeout
	can_air_jump = true

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

func dash(direction: float):
	if not can_dash or is_dashing: return
	
	var dash_dir = direction if direction != 0 else (1.0 if body.get_node("AnimatedSprite2D").flip_h == false else -1.0)
	
	is_dashing = true
	can_dash = false
	var original_v = body.velocity.y
	body.velocity.y = 0
	body.velocity.x = dash_dir * dash_speed
	
	await get_tree().create_timer(dash_duration).timeout
	
	is_dashing = false
	body.velocity.y = original_v * 0.5 
	body.velocity.x *= dash_drift
	
	await get_tree().create_timer(dash_cooldown).timeout
	can_dash = true
