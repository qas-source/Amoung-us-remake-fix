extends Node

const DEFAULT_IP = '127.0.0.1'
const DEFAULT_PORT = 8080
const MAX_PLAYERS = 10

var players = { }
var self_data = { id = 0, name = '', position = Vector2(0, 0), animation_state = 2, animation_stopped = true, imposter = false }
var game_started = false


func _ready():
    # Assigned to variables to supress warnings
    var _temp1 = get_tree().connect('network_peer_connected', self, '_on_player_connected')
    var _temp2 = get_tree().connect('network_peer_disconnected', self, '_on_player_disconnected')

func create_server(player_nickname):
    self_data.id = 1
    self_data.name = player_nickname
    players[1] = self_data
    var peer = NetworkedMultiplayerENet.new()
    peer.create_server(DEFAULT_PORT, MAX_PLAYERS)
    get_tree().set_network_peer(peer)


func connect_to_server(player_nickname, server_ip):
    self_data.name = player_nickname

    var peer = NetworkedMultiplayerENet.new()
    if server_ip == "":
        peer.create_client(DEFAULT_IP, DEFAULT_PORT)
    else:
        peer.create_client(server_ip, DEFAULT_PORT)
    get_tree().set_network_peer(peer)


func _on_player_connected(id):
    self_data.id = id
    players[id] = self_data
    rpc('register_player', id, self_data)


func _on_player_disconnected(id):
    players.erase(id)


remote func start_game(imposter_ids):
    game_started = true

    for player_id in players.keys():
        if player_id != self_data.id:
            if get_tree().is_network_server():
                rpc_id(player_id, "start_game", imposter_ids)

            var player_node = get_tree().get_root().get_node(players[player_id].name)

            if player_id in imposter_ids:
                player_node.imposter = true
                players[player_id].imposter = true
                if get_tree().is_network_server():
                    rpc_id(player_id, "enable_imposter")

            player_node.position = Vector2.ZERO
            if get_tree().is_network_server():
                rpc_id(player_id, "teleport", Vector2.ZERO)


remote func enable_imposter():
    get_tree().get_root().get_node(self_data.name).enable_imposter_ui()


remote func teleport(position):
    get_tree().get_root().get_node(self_data.name).position = position


remote func register_player(id, info):
    if get_tree().is_network_server():
        for player_id in players.keys():
            if player_id != self_data.id and player_id != id:
                rpc_id(player_id, "register_player", id, info)

    players[id] = info

    var new_player = load("res://src/actors/Player.tscn").instance()
    new_player.init(players[id].position, players[id].name, false)

    get_tree().get_root().add_child(new_player)


remote func update_player(id, position, animation_state, animation_stopped):
    if get_tree().is_network_server():
        for player_id in players.keys():
            if player_id != self_data.id:
                rpc_unreliable_id(player_id, "update_player", id, position, animation_state, animation_stopped)

    get_tree().get_root().get_node(players[id].name).position = position
    get_tree().get_root().get_node(players[id].name).animation_state = animation_state
    get_tree().get_root().get_node(players[id].name).animation_stopped = animation_stopped
    players[id].position = position
    players[id].animation_state = animation_state
    players[id].animation_stopped = animation_stopped
