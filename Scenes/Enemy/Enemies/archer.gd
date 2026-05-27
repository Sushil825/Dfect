extends BaseEnemy
class_name Archer

#Local vars

var _direction:Vector2=Vector2.RIGHT
var _player_direction:Vector2=Vector2.ZERO
var _target:Player=null
var _can_attack:bool=true
var _gravity:=980
var _can_dash:=false
var _dash_range:=200
var _is_dashing:=false

#Onreadies
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_component: HealthComponent = $HealthComponent
@onready var hurt_box: HurtBox = $HurtBox
@onready var state_chart: StateChart = $StateChart
@onready var detection_area: Area2D = $DetectionArea
@onready var arrow_spawn: Marker2D = $ArrowSpawn
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player_forget: Timer = $Timers/PlayerForget
@onready var dashabley: RayCast2D = $RayCasts/Dashabley
@onready var dashablex: RayCast2D = $RayCasts/Dashablex




#Export var

@export var idle_timer_min:float
@export var idle_timer_max:float
@export var walk_timer_min:float
@export var walk_timer_max:float
@export var arrow:PackedScene
@export var particle_effect:PackedScene
@export var time_to_forget_player:float
@export var dashing_cd:float
@export var dashing_range:float
@export var dash_duration:float


#Timers

@onready var idle_timer: Timer = $Timers/IdleTimer
@onready var attack_timer: Timer = $Timers/AttackTimer
@onready var walk_timer: Timer = $Timers/WalkTimer
@onready var dash_timer: Timer = $Timers/DashTimer




#Raycasts

@onready var is_wall: RayCast2D = $RayCasts/IsWall
@onready var is_ground: RayCast2D = $RayCasts/isGround






#Shader functions
#Signals








#Normal functions 


func _ready() -> void:
	attack_timer.wait_time=enemy_stat.attack_cd
	idle_timer.wait_time=randf_range(idle_timer_min,idle_timer_max)
	walk_timer.wait_time=randf_range(walk_timer_min,walk_timer_max)
	player_forget.wait_time=time_to_forget_player
	dash_timer.wait_time=dashing_cd
	dash_timer.start()
	health_component.max_health=enemy_stat.health
	health_component.health=enemy_stat.health
	

func apply_gravity(_delta:float):
	if !self.is_on_floor():
		
		if not _is_dashing:
			velocity.y+=_gravity*_delta


func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	move_and_slide()




func handle_animation(anim:String):
	animated_sprite_2d.play(anim)



func turn():
	_direction.x*=-1
	if _direction==Vector2.RIGHT:
		animated_sprite_2d.flip_h=false
	elif _direction==Vector2.LEFT:
		animated_sprite_2d.flip_h=true
	is_wall.target_position.x*=-1
	is_ground.position.x*=-1
	detection_area.scale.x*=-1
	arrow_spawn.position.x*=-1
	dashablex.target_position.x*=-1
	dashabley.position.x*=-1


func _on_idle_state_entered() -> void:
	velocity.x=0
	handle_animation("idle")
	idle_timer.start()


func _on_idle_state_physics_processing(delta: float) -> void:
	
	
	if _target:
		if _can_attack:
			state_chart.send_event("idle_to_attack")


func _on_walk_state_entered() -> void:
	handle_animation("run")
	walk_timer.start()


func _on_walk_state_physics_processing(delta: float) -> void:
	
	if _target:
		if _can_attack:
			state_chart.send_event("walk_to_attack")
	
	self.velocity.x = enemy_stat.walk_speed * _direction.x
	if is_wall.is_colliding():
		
		turn()

	if not is_ground.is_colliding():
		
		turn()



func _on_attack_state_entered() -> void:
	
	
	if _target.global_position.x>global_position.x and _direction.x<0:
		turn()
		
	elif _target.global_position.x<global_position.x and _direction.x>0:
		turn()
	
	velocity.x=0
	_can_attack=false
	handle_animation("attack")
	animation_player.play("attack")


func _on_attack_state_physics_processing(_delta: float) -> void:
	pass # Replace with function body.


func _on_dash_state_entered() -> void:
	velocity.x=0
	_can_dash=false
	
	state_chart.send_event("dash_to_bail")

func _on_dash_state_physics_processing(_delta: float) -> void:
	pass








#Not state processing or entered




func _on_idle_timer_timeout() -> void:
	state_chart.send_event("idle_to_walk")
	


func _on_walk_timer_timeout() -> void:
	state_chart.send_event("walk_to_idle")


func _on_detection_area_body_entered(body: Node2D) -> void:
	if body is not Player:
		return
		
	_target=body
	
	if _can_attack:
		if velocity.x!=0:
			state_chart.send_event("walk_to_attack")
		elif velocity.x==0:
			state_chart.send_event("idle_to_attack")
	else:
		if velocity.x!=0:
			state_chart.send_event("walk_to_bail")
		elif velocity.x==0:
			state_chart.send_event("idle_to_bail")


func _on_detection_area_body_exited(body: Node2D) -> void:
	player_forget.start()


func _on_bail_state_physics_processing(delta: float) -> void:
	
		
		
		if _can_dash:
			if not dashablex.is_colliding():
				if dashabley.is_colliding():
					state_chart.send_event("bail_to_dash")
					print("Can dash")
		
		velocity.x=enemy_stat.chase_speed*_direction.x
		
		if not is_ground.is_colliding():
			turn()
		elif is_wall.is_colliding():
			turn()
		
		
		if _can_attack:
			state_chart.send_event("bail_to_idle")
		


func _on_bail_state_entered() -> void:
	
	if !_target:
		return

	if _target.global_position.x > global_position.x and _direction.x > 0:
		turn()

	# Player is left but archer facing left
	elif _target.global_position.x < global_position.x and _direction.x < 0:
		turn()


func spawn_arrow():
	var new_arrow=arrow.instantiate()
	new_arrow.global_position=arrow_spawn.global_position
	if _direction.x>0:
		new_arrow.direction.x=1
	elif _direction.x<0:
		new_arrow.direction.x=-1
		
	get_tree().current_scene.add_child(new_arrow)

func _on_attack_timer_timeout() -> void:
	_can_attack=true
	
	
	
func _attack_done():
	state_chart.send_event("attack_to_bail")
	handle_animation("run")
	attack_timer.start()
	


func _on_player_forget_timeout() -> void:
	
	for area in detection_area.get_overlapping_bodies():
		if area is Player:
			return
	
	_target=null


func _on_dash_timer_timeout() -> void:
	_can_dash=false


func _on_hurt_box_hit_received(hitbos: HitBox) -> void:
	health_component.take_damage(hitbos.damage)
	Utils.flash(animated_sprite_2d,Color.RED,0.1)
	var new_effect=particle_effect.instantiate()
	new_effect.global_position=global_position
	get_tree().current_scene.add_child(new_effect)
