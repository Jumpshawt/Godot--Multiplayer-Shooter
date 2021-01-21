extends Impact

func _ready():
	$sound.pitch_scale = rand_range(0.8, 1.2)
	$particles.emitting = true
	$mesh.rotation.z = rand_range(-TAU, TAU)
	var rand_scale = rand_range(0.75, 1.25)
	$mesh.scale = Vector3(rand_scale, rand_scale, rand_scale)
