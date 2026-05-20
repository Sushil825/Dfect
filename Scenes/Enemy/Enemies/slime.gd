extends BaseEnemy
@onready var state_chart: StateChart = %StateChart
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@onready var ground_ray: RayCast2D = $GroundRay
@onready var wall_ray: RayCast2D = $WallRay
@onready var attack_ray: RayCast2D = $Attack
@onready var animation_player: AnimationPlayer = %AnimationPlayer

@onready var health_component: HealthComponent = $HealthComponent
@export var on_damage:PackedScene

var _direction:Vector2=Vector2.RIGHT
var _player_direction:Vector2=Vector2.ZERO
@export var _detection_radius:CollisionShape2D

var _target:Player=null
var _can_attack:bool=true


func flash(color:Color,time:float):
	var mat=$AnimatedSprite2D.material
	mat.set_shader_parameter("active",true)
	mat.set_shader_parameter("tint",color)
	await get_tree().create_timer(time).timeout
	mat.set_shader_parameter("active",false)


func _ready() -> void:
	health_component.max_health=enemy_stat.health
	health_component.health=health_component.max_health
	var shape=RectangleShape2D.new()
	shape.size=enemy_stat.chase_range
	_detection_radius.shape=shape
	

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
	flash(Color.RED,0.1)
	var new_damage=on_damage.instantiate()
	add_child(new_damage)
	
	
	
	


func turn():
	_direction.x*=-1
	wall_ray.target_position.x*=-1
	ground_ray.position.x*=-1
	_detection_radius.position*=-1
	attack_ray.target_position*=-1
	
	



func _on_walk_state_entered() -> void:
	$AnimatedSprite2D.play("walk")


func _on_walk_state_physics_processing(delta: float) -> void:
	velocity.x=self.enemy_stat.walk_speed*_direction.x
	
	
	if ground_ray.is_colliding():
		turn()
		
	if !wall_ray.is_colliding():
		turn()
		
	


func _on_detection_radius_body_entered(body: Node2D) -> void:
	if body is not Player:
		return
	_target=body
	state_chart.send_event("walk_to_chase")


func _on_detection_radius_body_exited(body: Node2D) -> void:
	if body==_target:
		_target=null


func _on_chase_state_entered() -> void:
	pass
		


func _on_chase_state_physics_processing(delta: float) -> void:
	if _target:
		_player_direction=(_target.global_position-global_position).normalized()
		var distance = global_position.distance_to(_target.global_position)

		if distance > 64:
			velocity.x = enemy_stat.chase_speed * _player_direction.x
		else:
			velocity.x = 0
		if _can_attack:
			if attack_ray.is_colliding():
				
				state_chart.send_event("chase_to_attack")
	else:
		state_chart.send_event("chase_to_walk")
		
		
	
		
		


func enable_hitbox():
	$HitBox.disable_mode=false
	
func disable_hitbox():
	$HitBox.disable_mode=true
	_can_attack=false
	get_tree().create_timer(enemy_stat.attack_cd).timeout.connect(_on_attack_cd_timeout)
	
func _on_attack_cd_timeout():
	_can_attack=true

func _on_attack_state_entered() -> void:
	velocity.x=0
	$AnimatedSprite2D.play("attack")
	animation_player.play("attack")
	flash(Color.WHITE,0.18)
	

func _on_attack_state_physics_processing(delta: float) -> void:
	
	if !attack_ray.is_colliding():
		state_chart.send_event("attack_to_chase")
