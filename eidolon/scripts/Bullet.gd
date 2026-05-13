extends Area2D

# --- CONFIGURACIÓN DE LA BALA ---
@export var speed: float = 1200.0
@export var damage: int = 1
@export var lifetime: float = 2.0

var direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	# Conectamos la señal de colisión por código para asegurar limpieza
	body_entered.connect(_on_body_entered)
	
	# Autodestrucción por tiempo para no saturar tu Arch Linux
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func setup(dir: Vector2) -> void:
	# Configuramos la dirección y rotación inicial
	direction = dir.normalized()
	rotation = direction.angle()

func _physics_process(delta: float) -> void:
	# Movimiento lineal constante
	position += direction * speed * delta

func _on_body_entered(body: Node) -> void:
	# 1. EFECTO DE IMPACTO (Aquí puedes instanciar chispas)
	# spawn_impact_particles()
	
	# 2. VERIFICACIÓN DE DAÑO (Si el cuerpo tiene salud)
	if body.has_method("take_damage"):
		body.take_damage(damage)
	
	# 3. HIT-STOP (Micro-pausa para dar sensación de peso)
	# Engine.time_scale = 0.05
	# await get_tree().create_timer(0.05, true, false, true).timeout
	# Engine.time_scale = 1.0
	
	# 4. DESTRUCCIÓN FINAL
	queue_free()
