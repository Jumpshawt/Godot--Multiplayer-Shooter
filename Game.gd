extends Spatial

onready var player1pos = $Player1Pos
onready var player2pos = $Player2Pos

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var player1 = preload("res://Player.tscn").instance()
	player1.set_name(str(get_tree().get_network_unique_id()))
	player1.set_network_master(get_tree().get_network_unique_id())
	player1.global_transform = player1pos.global_transform
	add_child(player1)
	
	var player2 = preload("res://Player.tscn").instance()
	player2.set_name(str(Globals.player2id))
	player2.set_network_master(Globals.player2id)
	player2.global_transform = player2pos.global_transform
	add_child(player2)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
