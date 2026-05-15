extends Area2D

@onready var hitbox = $HitboxComponent

# --- CONFIGURACIÓN DE LA BALA ---
@export var speed: float = 1200.0
@export var damage: int = 1
@export var lifetime: float = 2.0

var direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	hitbox.body_entered.connect(_on_impact)
	hitbox.area_entered.connect(_on_impact)
	
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func setup(dir: Vector2) -> void:
	direction = dir.normalized()
	rotation = direction.angle()

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

#func _on_body_entered(body: Node) -> void:
#	# 1. EFECTO DE IMPACTO (Aquí puedes instanciar chispas)
#	# spawn_impact_particles()
#	
#	# 2. VERIFICACIÓN DE DAÑO (Si el cuerpo tiene salud)
#	if body.has_method("take_damage"):
#		body.take_damage(damage)
#	
#	# 3. HIT-STOP (Micro-pausa para dar sensación de peso)
#	# Engine.time_scale = 0.05
#	# await get_tree().create_timer(0.05, true, false, true).timeout
#	# Engine.time_scale = 1.0
#	
#	# 4. DESTRUCCIÓN FINAL
#	queue_free()

func _on_impact(target: Node):
	print("Bala choco con:", target.name)
	if target.has_method("take_damage"):
		target.take_damage(damage)
	elif target.get_parent().has_method("take_damage"):
		target.get_parent().take_damage(damage)

	queue_free()
