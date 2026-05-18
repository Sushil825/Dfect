extends Area2D
class_name HurtBox


@export var is_invincible:bool=false
signal hit_received(hitbos:HitBox)




func take_hit(hitbox:HitBox):
	if is_invincible:
		return
		
		
	hit_received.emit(hitbox)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
