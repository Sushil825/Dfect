extends BaseEnemy
class_name Zombie

#Local vars

var _direction:Vector2=Vector2.RIGHT
var _player_direction:Vector2=Vector2.ZERO
var _target:Player=null
var _can_attack:bool=true
var _gravity:=980



#Export vars


@export var idle_time_min:float
@export var idle_time_max:float
@export var walk_time_min:float
@export var walk_time_max:float


@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_component: HealthComponent = $HealthComponent
@onready var hurt_box: HurtBox = $HurtBox
@onready var iswall: RayCast2D = $RayCasts/iswall
@onready var no_floor: RayCast2D = $RayCasts/no_floor
@onready var player_in_range: RayCast2D = $RayCasts/player_in_range
@onready var state_chart: StateChart = $StateChart
@onready var hit_box: HitBox = $HitBox
@onready var detection_range: Area2D = $DetectionRange




#Timers
@onready var walk_timer: Timer = $Timers/walk_timer
@onready var idle_timer: Timer = $Timers/idle_timer
@onready var player_in_memory: Timer = $Timers/player_in_memory





func _ready() -> void:
	idle_timer.wait_time=randf_range(idle_time_min,idle_time_max)
	walk_timer.wait_time=randf_range(walk_time_min,walk_time_max)
	idle_timer.start()



func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	move_and_slide()
	
	
func _process(delta: float) -> void:
	pass
	

func apply_gravity(_delta:float):
	if !self.is_on_floor():
		velocity.y+=_gravity*_delta

	
func handle_animation(str:String):
	$AnimatedSprite2D.play(str)
	

func turn():
	_direction.x*=-1
	if _direction==Vector2.RIGHT:
		animated_sprite_2d.flip_h=false
	elif _direction==Vector2.LEFT:
		animated_sprite_2d.flip_h=true
		
	iswall.target_position.x*=-1
	no_floor.position.x*=-1
	detection_range.scale.x*=-1




func _on_idle_state_entered() -> void:
	velocity.x=0
	handle_animation("idle")


func _on_idle_state_physics_processing(delta: float) -> void:
	pass # Replace with function body.


func _on_walk_state_entered() -> void:
	handle_animation("run")


func _on_walk_state_physics_processing(delta: float) -> void:
	self.velocity.x = enemy_stat.walk_speed * _direction.x
	if iswall.is_colliding():
		
		turn()

	if not no_floor.is_colliding():
		print("What")
		turn()


func _on_chase_state_entered() -> void:
	pass # Replace with function body.


func _on_chase_state_physics_processing(delta: float) -> void:
	pass # Replace with function body.


func _on_attack_state_entered() -> void:
	pass # Replace with function body.


func _on_attack_state_physics_processing(delta: float) -> void:
	pass # Replace with function body.


func _on_death_state_entered() -> void:
	pass # Replace with function body.


func _on_death_state_physics_processing(delta: float) -> void:
	pass # Replace with function body.


func _on_idle_timer_timeout() -> void:
	state_chart.send_event("idle_to_walk")
	walk_timer.wait_time=randf_range(walk_time_min,walk_time_max)
	walk_timer.start()


func _on_walk_timer_timeout() -> void:
	state_chart.send_event("walk_to_idle")
	idle_timer.wait_time=randf_range(idle_time_min,idle_time_max)
	idle_timer.start()


func _on_detection_range_body_entered(body: Node2D) -> void:
	if body is not Player:
		return
		
	_target=body


func _on_detection_range_body_exited(body: Node2D) -> void:
	player_in_memory.start()


func _on_player_in_memory_timeout() -> void:
	_target=null
