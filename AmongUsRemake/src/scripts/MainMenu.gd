extends Control

var player_name: String = "Anonymous"
var server_ip: String = ""


func _on_NameEntry_text_changed(new_name):
	player_name = new_name


func _on_IPEntry_text_changed(new_ip):
	server_ip = new_ip


func _on_HostButton_pressed():
	Network.create_server(player_name)
	get_tree().change_scene("res://src/scenes/Skeld.tscn")


func _on_JoinButton_pressed():
	Network.connect_to_server(player_name, server_ip)
	get_tree().change_scene("res://src/scenes/Skeld.tscn")
