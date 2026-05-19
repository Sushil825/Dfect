extends HitBox
class_name DeathZone
@export var one_shot_kill:bool=false

func _ready() -> void:
	area_entered.connect(_on_area_entered)


func disable_trap():
	monitoring=false


func _on_area_entered(area:Area2D)->void:
	print("whut")
	if not area is HurtBox:
		return
		
	var hurtbox=area as HurtBox
	var already_hit:=one_shot and _has_hit
	
	if already_hit or hurtbox.is_invincible:
		return
	
	
	_has_hit=true
	hurtbox.take_hit(self)
	hit.emit(hurtbox)
