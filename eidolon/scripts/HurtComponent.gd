# HurtComponent.gd
extends Area2D
class_name HurtComponent

@export var health_component: HealthComponent

func _ready():
	area_entered.connect(_on_area_entered)

func _on_area_entered(hitbox: Area2D):
	if hitbox is HitboxComponent: # Necesitarás crear un HitboxComponent para proyectiles
		health_component.damage(hitbox.damage)
