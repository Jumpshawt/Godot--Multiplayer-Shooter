extends Node
#this script is a singleton, meaning it runs indipendently of the game, meaning we can call stuff from here from any point in the game
var player2id = -1
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var spawns = []
var respawn1 = Vector3()
var respawn2 = Vector3()
var raycast1_point = Vector3()
var players = { }
var self_points = 0
var self_deaths = 0
var self_kills = 0
var surf_location = Vector3()
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
