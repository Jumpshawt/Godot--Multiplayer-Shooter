extends Spatial

func _ready():
	# Get the viewport and clear it.
	var viewport = get_node("Viewport")
	viewport.set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)

	# Let two frames pass to make sure the vieport is captured.

	# Retrieve the texture and set it to the viewport quad.
	get_node("Viewport_quad").material_override.albedo_texture = viewport.get_texture()

func _process(delta):
	var camera_pos = get_viewport().get_camera().global_transform.origin
	camera_pos.y = self.global_transform.origin.y
	look_at(camera_pos, Vector3(0, 1, 0))
