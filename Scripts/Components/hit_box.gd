extends Area2D
class_name HitBox

signal hit(hurtbox:HurtBox)
@export var damage:int=1
@export var one_shot:bool=false
var _has_hit:bool=false



func _ready() -> void:
	monitorable=false
	area_entered.connect(_on_area_entered)
	

func reset()->void:
	_has_hit=false

func _on_area_entered(area:Area2D)->void:
	if not area is HurtBox:
		return
		
	var hurtbox=area as HurtBox
	var already_hit:=one_shot and _has_hit
	
	if already_hit or hurtbox.is_invincible:
		return
	
	
	_has_hit=true
	hurtbox.take_hit(self)
	hit.emit(hurtbox)
