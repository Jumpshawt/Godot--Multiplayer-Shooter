extends Spatial
class_name Impact

var lifetime : float = 5.0

func _ready():
	pass

func _physics_process(delta):
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()
