extends Node
class_name HealthComponent


@export var max_health:int=30
@export var health:int=0


func _ready() -> void:
	health=max_health


func take_damage(dmg:int):
	health-=dmg
	print(health)
	if health<=0:
		get_parent().queue_free()
