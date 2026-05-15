extends StaticBody2D

@onready var health_component = $HealthComponent
@onready var animation_player = $AnimationPlayer

func _ready():
	health_component.died.connect(_on_died)
	health_component.health_changed.connect(_on_health_changed)

func _on_health_changed(current_health: int):
	# Visual effect
	if animation_player.has_animation("hit_flash"):
		animation_player.play("hit_flash")
	
	# shake
	print("Diana herida. Vida restante: ", current_health)

func _on_died():
	print("Diana eliminada por el sistema.")
	# Explosion effect
	queue_free()

# Para compatibilidad con tu ShootComponent actual (Melee)
func take_damage(amount: int):
	health_component.damage(amount)

# Para compatibilidad con tus balas actuales
func handle_hit(damage: int, _dir: Vector2):
	health_component.damage(damage)
