extends CharacterBody2D
class_name Player
@export var GRAVITY:int=980
@onready var state_chart: StateChart = $StateChart
@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var player_state_handler: Node = $PlayerStateHandler



var direction=Vector2.RIGHT
func _physics_process(delta: float) -> void:
	handle_input()
	check_gravity(delta)
	move_and_slide()



func check_gravity(_delta):
	if not is_on_floor():
		velocity.y+=GRAVITY*_delta


func check_direction():
	if Input.get_axis("go_left","go_right")<0:
		direction=Vector2.LEFT
		animated_sprite_2d.flip_h=true
	elif Input.get_axis("go_left","go_right")>0:
		direction=Vector2.RIGHT
		animated_sprite_2d.flip_h=false


func handle_input():
	pass
