extends BaseEnemy
@onready var state_chart: StateChart = %StateChart
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@onready var health_component: HealthComponent = $HealthComponent





func _ready() -> void:
	health_component.max_health=enemy_stat.health
	health_component.health=health_component.max_health
	

var GRAVITY:=980

func _physics_process(delta: float) -> void:
	check_gravity(delta)
	move_and_slide()
	


func check_gravity(_delta):
	if not is_on_floor():
		velocity.y+=GRAVITY*_delta

func _on_idle_state_entered() -> void:
	animated_sprite_2d.play("idle")


func _on_idle_state_physics_processing(delta: float) -> void:
	pass # Replace with function body.


func _on_hurt_box_hit_received(hitbox: HitBox) -> void:
	health_component.take_damage(hitbox.damage)
