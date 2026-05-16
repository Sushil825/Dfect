extends Node
class_name PlayerStateHandler
@export var player:Player
@export var player_stats:PlayerStats
@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var state_chart: StateChart = $"../StateChart"




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
	
	if Input.is_action_just_pressed("jump"):
			state_chart.send_event("run_to_jump")
	
	if not Input.is_action_pressed("run"):
		if Input.get_axis("go_left","go_right")!=0:
			state_chart.send_event("run_to_walk")
		
		else:
			state_chart.send_event("run_to_idle")
	
	player.velocity.x=player_stats.run_speed*player.direction.x


func _on_run_state_entered() -> void:
	handle_animation("run")
