extends Node2D
class_name DecorationSpawner
@export var PossibleLocations:Array[Area2D]=[]
@export var Decorations:Array[PackedScene]
@export var no_of_decoration_to_spawn:int=1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	if not Decorations:
		return
	
	for i in range(no_of_decoration_to_spawn):
		spawn_decs()


func spawn_decs():
	
	var new_dec=Decorations.pick_random().instantiate()
	var new_location=PossibleLocations.pick_random()
	var shape:CollisionShape2D
	for child in new_location.get_children():
		if child is CollisionShape2D:
			shape=child
		else:
			return
	
	var top_left=shape.global_position-shape.shape.size/2
	var bottom_right=shape.global_position+shape.shape.size/2
	var random_pos=Vector2(
		randi_range(int(top_left.x),int(bottom_right.x)),
		randi_range(int(top_left.y),int(bottom_right.y))
	)
	
	new_dec.global_position=random_pos
	add_child(new_dec)
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
