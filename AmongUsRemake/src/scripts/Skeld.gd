extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var new_player = preload("res://src/actors/Player.tscn").instance()
	var player_name = Network.self_data.name
#	new_player.set_network_master(player_id)
	new_player.init(Network.self_data.position, player_name, true)
	get_tree().get_root().add_child(new_player)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
