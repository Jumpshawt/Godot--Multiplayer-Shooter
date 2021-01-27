extends Spatial

onready var SpawnPoints = $SpawnPoints
onready var player1pos = $SpawnPoints/Player1Pos
onready var player2pos = $SpawnPoints/Player2Pos

var players = {}

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var self_data = {name = ''}

const MAX_PLAYERS : int = 32 
var ip_adress = "127.0.0.1"

# Called when the node entsers the scene tree for the first time.
func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	_get_spawnpoints()
	pass



func _create_server(player_nickname):
	self_data.name = player_nickname
	Globals.players[1] = self_data
	print(Globals.players[1])
	var port = int($Lobby/port.text)
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(port, MAX_PLAYERS)
	get_tree().set_network_peer(peer)
	print("hosting")
	_add_player(get_tree().get_network_unique_id(), self_data.name , 1)
	pass # Replace with function body.

remote func _send_player_info(id, info):
	if get_tree().is_network_server():
		for peer_id in players:
			rpc_id(id, '_send_player_info', peer_id, players[peer_id])
	var pconnect = {name = ''}
	pconnect.name = info
	pconnect.points = info 
	Globals.players[id] = pconnect
	

func connect_to_server(player_nickname):
	self_data.name = player_nickname
	get_tree().connect("connected_to_server",self, '_connected_to_server')
	ip_adress = $Lobby/ip.text
	var port = int($Lobby/port.text)
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip_adress, port)
	get_tree().set_network_peer(peer)


func _connected_to_server():
	Globals.players[get_tree().get_network_unique_id()] = self_data
	rpc('_send_player_info', get_tree().get_network_unique_id(), self_data.name)
	_add_player(get_tree().get_network_unique_id(), self_data.name , 1)


func _on_Button_join_pressed():
	connect_to_server($Lobby/TextEdit.text)

func _player_connected(id):
	print("player ", id , 'has connected')
	Globals.player2id = id
	_add_player(get_tree().get_network_unique_id(), self_data.name , 2)
	rpc('_send_player_info', get_tree().get_network_unique_id(), self_data.name)


func _add_player(id, name, pnum):
	match pnum:
		1:
			var player1 = preload("res://Player.tscn").instance()
			player1.set_name(str(id))
			player1.set_network_master(id)
			player1.global_transform = player1pos.global_transform
			Globals.respawn1 = player1pos.global_transform
			print("adding player 1 at" , player1pos.global_transform)
			add_child(player1)
			menu_vis()
		2:
			var player2 = preload("res://Player.tscn").instance()
			player2.set_name(str(Globals.player2id))
			player2.set_network_master(Globals.player2id)
			player2.global_transform = player2pos.global_transform
			Globals.respawn2 = player2pos.global_transform
			add_child(player2)
			menu_vis()

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

func _on_Button_Host_pressed():
	_create_server($Lobby/TextEdit.text)
