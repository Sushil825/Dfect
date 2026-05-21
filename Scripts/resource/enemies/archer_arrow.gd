extends Sprite2D


var direction:=Vector2.RIGHT
var speed:=400.0


func _physics_process(delta: float) -> void:
	
	
	if direction==Vector2.LEFT:
		rotation_degrees=180
	
	position+=direction*speed*delta
