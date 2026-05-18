extends Node
class_name PlayerStateHandler
@export var sword_collider:CollisionShape2D
@export var player:Player
@export var player_stats:PlayerStats
@export var weapon_stats:Weapon
@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var state_chart: StateChart = $"../StateChart"

@onready var hit_box: HitBox = $"../HitBox"
@onready var animation_player: AnimationPlayer = %AnimationPlayer


#Timers
@export var attack_timer:Timer


#Signals



var can_attack:bool=true


func _ready() -> void:
	attack_timer.wait_time=weapon_stats.attack_cd
	
	hit_box.monitoring=false
	hit_box.damage=weapon_stats.attack_base_damage
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


func _on_jump_state_physics_processing(delta: float) -> void:
	if player.velocity.y>=0:
		state_chart.send_event("jump_to_fall")
		
	if Input.get_axis("go_left","go_right"):
		player.velocity.x=(player_stats.walk_speed*player.direction.x)
		
		
		
	if Input.is_action_just_released("jump") and player.velocity.y<0:
		player.velocity.y*=0.5



func _on_jump_state_entered() -> void:
	handle_animation("jump")
	player.velocity.y=player_stats.jump_force


func _on_fall_state_entered() -> void:
	handle_animation("fall")
	
func _on_fall_state_physics_processing(delta: float) -> void:
	if player.is_on_floor():
		state_chart.send_event("fall_to_idle")
		
		
	if Input.get_axis("go_left","go_right"):
		player.velocity.x=(player_stats.walk_speed*player.direction.x)


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


func _on_attack_state_entered() -> void:
	if can_attack:
		animation_player.play("attack_animation")
	can_attack=false
	
func _on_attack_state_physics_processing(delta: float) -> void:
	pass

func _on_not_attack_state_entered() -> void:
	pass


func _on_not_attack_state_physics_processing(delta: float) -> void:
	if Input.is_action_just_pressed("attack") and can_attack:
		state_chart.send_event("na_to_attack")



	
	
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
