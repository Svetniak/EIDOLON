# HealthComponent.gd
extends Node
class_name HealthComponent

@export var max_health: int = 3
var current_health: int

signal on_died
signal on_health_changed(new_health)

func _ready():
	current_health = max_health

func damage(amount: int):
	current_health -= amount
	on_health_changed.emit(current_health)
	if current_health <= 0:
		on_died.emit()
