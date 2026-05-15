extends Area2D
class_name DamageComponent

@export var health_component: HealthComponent

func receive_damage(amount: int):
	if heath_component:
		health_component.damage(amount)
