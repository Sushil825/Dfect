extends Camera2D


@onready var _offset:Vector2=self.offset
@export var _target:Player
@export var transition_type:Tween.TransitionType
@export var easing_type:Tween.EaseType

var _look_ahead_tween:Tween
@export var _look_ahead_duration:float=1

func _ready() -> void:
	if _target and _target is Player:
		_target.changed_direction.connect(_on_player_changed_direction)


func _on_player_changed_direction(direction:float)->void:
	if _look_ahead_tween:
		_look_ahead_tween.kill()
	_look_ahead_tween=create_tween().set_trans(transition_type).set_ease(easing_type)
	_look_ahead_tween.tween_property(self,"offset:x",_offset.x*sign(direction),_look_ahead_duration)


func _process(_delta: float) -> void:
	if _target:
		position=_target.global_position
