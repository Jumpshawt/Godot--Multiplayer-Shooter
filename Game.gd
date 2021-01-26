extends Spatial

onready var SpawnPoints = $SpawnPoints
onready var player1pos = $SpawnPoints/Player1Pos
onready var player2pos = $SpawnPoints/Player2Pos

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const MAX_PLAYERS : int = 32 
var ip_adress = "127.0.0.1"

# Called when the node entsers the scene tree for the first time.
func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	_get_spawnpoints()
	pass

func _on_Button_Host_pressed():
	ip_adress = $Lobby/ip.text
	var port = int($Lobby/port.text)
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(port, MAX_PLAYERS)
	get_tree().set_network_peer(peer)
	print("hosting")
	var player1 = preload("res://Player.tscn").instance()
	player1.set_name(str(get_tree().get_network_unique_id()))
	player1.set_network_master(get_tree().get_network_unique_id())
	player1.global_transform = player1pos.global_transform
	Globals.respawn1 = player1pos.global_transform
	print("adding player 1 at" , player1pos.global_transform)
	add_child(player1)
	menu_vis()
	pass # Replace with function body.


func _on_Button_join_pressed():
	ip_adress = $Lobby/ip.text
	var port = int($Lobby/port.text)
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip_adress, port)
	get_tree().set_network_peer(peer)
	var player1 = preload("res://Player.tscn").instance()
	player1.set_name(str(get_tree().get_network_unique_id()))
	player1.set_network_master(get_tree().get_network_unique_id())
	player1.global_transform = player1pos.global_transform
	Globals.respawn1 = player1pos.global_transform
	print("adding player 1 at" , player1pos.global_transform)
	add_child(player1)
	menu_vis()
	pass # Replace with function body.

func _player_connected(id):
	print("epic")
	Globals.player2id = id
	var player2 = preload("res://Player.tscn").instance()
	player2.set_name(str(Globals.player2id))
	player2.set_network_master(Globals.player2id)
	player2.global_transform = player2pos.global_transform
	Globals.respawn2 = player2pos.global_transform
	print("adding player 2 at" , player2pos.global_transform)
	add_child(player2)

func _player_disconnected(id):
	print("player ", id, " has disconnected")
	get_node(str(id)).call_deferred("queue_free")
	rpc_unreliable("_player_free", id)
	pass

remote func _player_free(id):
	get_node(str(id)).call_deferred("queue_free")

func menu_vis():
	$Lobby.visible = false
	pass
func _get_spawnpoints():
	for N in SpawnPoints.get_children():
		Globals.spawns.append(N.global_transform)
