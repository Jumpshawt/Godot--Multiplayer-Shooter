extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	#first Netowkr peer connected is a built in function for when a client joins a server
	# second means to connect to self
	#third is the function name 
	get_tree().connect("network_peer_connected", self, "_player_connected")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_Host_pressed():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(4242, 32)
	get_tree().set_network_peer(peer)
	print("hosting")


func _on_Button_join_pressed():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client("127.0.0.1", 4242)
	get_tree().set_network_peer(peer)
func _player_connected(id):
	print("epic")
	Globals.player2id = id
	
	var game = preload("res://Game.tscn").instance()
	get_tree().get_root().add_child(game)
	hide()

