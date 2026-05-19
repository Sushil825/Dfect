extends DeathZone

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	super()
	animation_player.play("attack")


func enable_hitbox():
	monitoring=true
	
	
func disable_hitbox():
	monitoring=false
