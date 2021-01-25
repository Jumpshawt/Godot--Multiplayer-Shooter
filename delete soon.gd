extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	for N in self.get_children():
		print(N.global_transform)
		array.append(N.global_transform)
	print(array)
	var item = array[randi() % array.size()]
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
