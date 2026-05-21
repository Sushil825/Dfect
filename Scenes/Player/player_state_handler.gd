extends Node
class_name PlayerStateHandler
@export var sword_collider:CollisionShape2D
@export var player:Player
@export var player_stats:PlayerStats
@export var weapon_stats:Weapon
@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var state_chart: StateChart = $"../StateChart"
@onready var animation_player: AnimationPlayer = %AnimationPlayer



#Componennt
@onready var hit_box: HitBox = $"../HitBox"
@onready var hurt_box: HurtBox = $"../HurtBox"
@onready var health_component: HealthComponent = $"../HealthComponent"


#Timers
@export var attack_timer:Timer
@onready var coyote_timer: Timer = $"../Timers/coyote_timer"








#SFX and music

@onready var sword_attack: AudioStreamPlayer2D = $"../sword_attack"

#Signals



#Coyote
var can_coyote_jump:=false
var was_on_floor:=false


var _current_jumps:int=1


var can_attack:bool=true
var is_attacking:bool=false


func _ready() -> void:
	attack_timer.wait_time=weapon_stats.attack_cd
	
	hit_box.monitoring=false
	hit_box.damage=weapon_stats.attack_base_damage
	

#All Things irresepective of states happens

func do_jump():
	player.velocity.y=player_stats.jump_force


func _physics_process(delta: float) -> void:
	if was_on_floor and !player.is_on_floor():
		can_coyote_jump=true
		coyote_timer.start()
		
	was_on_floor=player.is_on_floor()


func _process(delta: float) -> void:
	handle_input()


func handle_input():
	player.check_direction()
	if player.is_on_floor():
		if Input.is_action_just_pressed("jump"):
				state_chart.send_event("to_jump")
	if not player.is_on_floor():
		pass


#Walk Run state vars

func handle_animation(anim:String):
	animated_sprite_2d.animation=anim
	animated_sprite_2d.play()



#All Things irresepective of states happens (UP) 




#IDle state


func _on_idle_state_physics_processing(delta: float) -> void:
	
	if player.is_on_floor():
		if Input.is_action_pressed("run"):
			if Input.get_axis("go_left","go_right")!=0:
				state_chart.send_event("idle_to_run")
		if Input.get_axis("go_left","go_right")!=0:
			state_chart.send_event("idle_to_walk")
	


func _on_idle_state_entered() -> void:
	player.velocity.x=0
	handle_animation("idle")





#Walk State


func _on_walk_state_physics_processing(delta: float) -> void:

	player.velocity.x=player_stats.walk_speed*player.direction.x
	if player.is_on_floor():
		if Input.get_axis("go_left","go_right")==0:
			state_chart.send_event("walk_to_idle")
	
	if Input.is_action_just_pressed("jump"):
		state_chart.send_event("walk_to_jump")
	
	if Input.is_action_pressed("run"):
		if Input.get_axis("go_left","go_right")!=0:
			state_chart.send_event("walk_to_run")
	
	if player.velocity.y>5:
		state_chart.send_event("walk_to_fall")


func _on_walk_state_entered() -> void:
	handle_animation("walk")






#Jump State

func _on_jump_state_physics_processing(delta: float) -> void:
	
	if player_stats.max_jumps>_current_jumps:
		if Input.is_action_just_pressed("jump"):
			do_jump()
			_current_jumps+=1
	
	if player.velocity.y>=0:
		state_chart.send_event("jump_to_fall")
		
	if Input.get_axis("go_left","go_right"):
		player.velocity.x=(player_stats.walk_speed*player.direction.x)
		
		
		
	if Input.is_action_just_released("jump") and player.velocity.y<0:
		player.velocity.y*=0.5



func _on_jump_state_entered() -> void:
	handle_animation("jump")
	do_jump()
	_current_jumps+=1





#Fall state

func _on_fall_state_entered() -> void:
	handle_animation("fall")
	
func _on_fall_state_physics_processing(delta: float) -> void:
	
	
	if player_stats.max_jumps>_current_jumps:
		if Input.is_action_just_pressed("jump"):
			do_jump()
			_current_jumps+=1
	
	if player.is_on_floor():
		_current_jumps=0
		state_chart.send_event("fall_to_idle")
		
	
	
	if Input.get_axis("go_left","go_right"):
		player.velocity.x=(player_stats.walk_speed*player.direction.x)





#Run state

func _on_run_state_physics_processing(delta: float) -> void:
	player.velocity.x=player_stats.run_speed*player.direction.x
	if player.velocity.y>5:
		state_chart.send_event("run_to_fall")
	
	if Input.is_action_just_pressed("jump"):
			state_chart.send_event("run_to_jump")
	
	if not Input.is_action_pressed("run"):
		if Input.get_axis("go_left","go_right")!=0:
			state_chart.send_event("run_to_walk")
		
		else:
			state_chart.send_event("run_to_idle")


func _on_run_state_entered() -> void:
	handle_animation("run")





#Attack state

func _on_attack_state_entered() -> void:
	if can_attack:
		animation_player.play("attack_animation")
		sword_attack.play()
		
		is_attacking=true
	can_attack=false
	
func _on_attack_state_physics_processing(delta: float) -> void:
	pass

func _on_not_attack_state_entered() -> void:
	is_attacking=false
	


func _on_not_attack_state_physics_processing(delta: float) -> void:
	if Input.is_action_just_pressed("attack") and can_attack:
		state_chart.send_event("na_to_attack")



#Attack functions

func enable_hitbox():
	hit_box.monitoring=true
	animated_sprite_2d.play("attack")
	if player.direction==Vector2.RIGHT:
		sword_collider.position.x=abs(sword_collider.position.x)
	elif player.direction==Vector2.LEFT:
		sword_collider.position.x=-abs(sword_collider.position.x)
		
		

func disable_hitbox():
	hit_box.monitoring=false
	attack_timer.start()
	state_chart.send_event("attack_to_na")
	animated_sprite_2d.play("attack_end")
	
	


func _on_attack_timer_timeout() -> void:
	can_attack=true
	


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation=="attack_end":
		if player.velocity==Vector2.ZERO:
			handle_animation("idle")
		elif Input.is_action_pressed("run"):
			handle_animation("run")
		else:
			handle_animation("walk")


func _on_hurt_box_hit_received(hitbos: HitBox) -> void:
	pass


func _on_coyote_timer_timeout() -> void:
	can_coyote_jump=false
