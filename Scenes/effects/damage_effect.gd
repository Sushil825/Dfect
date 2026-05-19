extends Node2D
class_name NormalOnHitEffect
@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D


func _ready() -> void:
	gpu_particles_2d.one_shot=true
