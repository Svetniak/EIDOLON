extends Node2D
class_name ShootComponent

@export var bullet_scene: PackedScene

@export_group("Fire Settings")
@export var fire_rate: float = 0.15
@export var recoil_strength: float = 50.0
@export var spread: float = 0.05

@export_group("Visual Effects")
@export var muzzle_flash_scene: PackedScene
@export var bullet_casing_scene: PackedScene

@export_group("Charge Settings")
@export var charge_time_required: float = 1.0
@export var explosion_pushback: float = 600.0
@export var self_damage: int = 1

@export_group("Heat System")
@export var heat_limit: float = 10.0
@export var heat_cooldown_speed: float = 2.0
@export var overheat_penalty_time: float = 3.0

var can_shoot: bool = true
var charge_timer: float = 0.0
var is_charging: bool = false
var current_heat: float = 0.0
var is_overheated: bool = false

func _process(delta: float):
	# 1. Lógica de Carga
	if is_charging:
		charge_timer += delta
	
	# 2. Lógica de Enfriamiento Pasivo
	if not is_overheated and current_heat > 0:
		current_heat = move_toward(current_heat, 0.0, heat_cooldown_speed * delta)

func shoot(direction: Vector2):
	# PRIMERO: Revisamos si podemos hacer algo
	if not can_shoot: return

	# SEGUNDO: Si está caliente, ¡MELEE!
	if is_overheated:
		execute_melee_attack()
		_start_cooldown(fire_rate * 2) # El melee es un poco más lento
		return

	# TERCERO: Disparo Normal
	if bullet_scene == null: return
	
	_execute_normal_shot(direction)
	
	# CALOR
	current_heat += 1.5
	if current_heat >= heat_limit:
		trigger_overheat()

	_start_cooldown(fire_rate)

func _execute_normal_shot(direction: Vector2):
	var bullet = bullet_scene.instantiate()
	var random_offset = Vector2(0, randf_range(-spread, spread))
	var final_dir = (direction + random_offset).normalized()
	
	get_tree().current_scene.add_child(bullet)
	var offset_x = abs(position.x) * sign(direction.x)

	bullet.global_position = get_parent().global_position + Vector2(offset_x, position.y)
	bullet.setup(final_dir)

	# RECOIL
	var player = get_parent() as CharacterBody2D
	if player:
		player.velocity -= direction * recoil_strength

		if not player.is_on_floor() and direction.y > 0.5:
			player.velocity.y -= recoil_strength * 1.5

	# MUZZLE FLASH
	if muzzle_flash_scene:
		var flash = muzzle_flash_scene.instantiate()
		add_child(flash)
		flash.global_position = global_position

func _start_cooldown(time: float):
	can_shoot = false
	await get_tree().create_timer(time).timeout
	can_shoot = true

func start_charging():
	if is_overheated: return
	is_charging = true
	charge_timer = 0.0

func release_charge(direction: Vector2):
	if not is_charging: return
	is_charging = false

	if charge_timer >= charge_time_required:
		execute_plasma_explosion(direction)
	else:
		shoot(direction) # Si no cargó suficiente, dispara normal

	charge_timer = 0.0

func execute_plasma_explosion(direction: Vector2):
	var player = get_parent() as CharacterBody2D
	if player:
		# Empuje violento (Salto extra)
		player.velocity = -direction * explosion_pushback
		if player.has_method("take_damage"):
			player.take_damage(self_damage)
	
	# Aquí podrías llamar a una función para instanciar metralla pesada
	print("BOOM! Plasma Explosion")
	trigger_overheat() # Una explosión sobrecalienta el arma instantáneamente

func trigger_overheat():
	is_overheated = true
	# Aquí podrías cambiar el color del arma a rojo
	await get_tree().create_timer(overheat_penalty_time).timeout
	is_overheated = false
	current_heat = 0.0

func execute_melee_attack():
	var melee_area = $MeleeArea
	if not melee_area: return
	
	var targets = melee_area.get_overlapping_bodies()
	for target in targets:
		if target.has_method("take_damage"):
			target.take_damage(2)
			
			# Knockback al enemigo
			var player = get_parent()
			var punch_dir = Vector2.LEFT if player.get_node("AnimatedSprite2D").flip_h else Vector2.RIGHT
			if target is CharacterBody2D:
				target.velocity = punch_dir * 400
