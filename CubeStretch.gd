extends Spatial

var look_at1 = Vector3()
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	self.look_at(look_at1, Vector3(0,1,0))
	self.scale.z = self.global_transform.origin.distance_to(look_at1)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.scale.x -= delta
	self.scale.y -= delta
	if self.scale.y < 0:
		queue_free()
	
	
	pass
