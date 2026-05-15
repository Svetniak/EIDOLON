extends Node
class_name HealthComponent

signal health_changed(current_health)
signal died

@export var max_health: int = 10
@onready var current_health: int = max_health

func damage(amount: int):
	current_health -= amount
	health_changed.emit(current_health)

	if current_health <=0:
		died.emit()

func heal(amount: int):
	current_health = min(current_health + amount, max_health)
	health_changed.emit(current_health)
