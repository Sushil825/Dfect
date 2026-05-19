extends Node2D
@export var room_name:String
@export var tile_map_layer:TileMapLayer

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D


func _ready() -> void:
	audio_stream_player_2d.play()
