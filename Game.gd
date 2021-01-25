extends Spatial

onready var player1pos = $Player1Pos
onready var player2pos = $Player2Pos

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node entsers the scene tree for the first time.
func _ready():
	var player1 = preload("res://Player.tscn").instance()
	player1.set_name(str(get_tree().get_network_unique_id()))
	player1.set_network_master(get_tree().get_network_unique_id())
	player1.global_transform = player1pos.global_transform
	Globals.respawn1 = player1pos.global_transform
	print("adding player 1 at" , player1pos.global_transform)
	add_child(player1)
	
	var player2 = preload("res://Player.tscn").instance()
	player2.set_name(str(Globals.player2id))
	player2.set_network_master(Globals.player2id)
	Globals.respawn2 = player2pos.global_transform
	player2.global_transform = player2pos.global_transform
	print("adding player 2 at" , player2pos.global_transform)
	add_child(player2)


#func _process(delta):
#	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
