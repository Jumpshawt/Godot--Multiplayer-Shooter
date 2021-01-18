extends KinematicBody

var speed = 5
var direction = Vector3()


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


#set position is called by the client
remote func _set_position(pos):
	global_transform.origin = pos
	
#test line plz remove later
remote func _printshit(lol):
	print("lolepic")

# Called when the node enters the scene tree for the first time.
func _ready():
	print('test')
	if !is_network_master():
		print('rotate helper master true')
		$Rotation_Helper/Camera.current = false
	else:
		$Rotation_Helper/Camera.current = true
		print('rotate helper master false')
	pass # Replace with function body.

func _physics_process(delta):
	direction = Vector3()
	
	if Input.is_action_pressed("ui_left"):
		direction -= transform.basis.x
	elif Input.is_action_pressed("ui_right"):
		direction += transform.basis.x
	if Input.is_action_just_pressed("ui_up"):
		rpc("_printshit", global_transform.origin)
	direction = direction.normalized()
	
	if direction != Vector3():
		if is_network_master():
			move_and_slide(direction * speed, Vector3.UP)
		rpc_unreliable("_set_position", global_transform.origin)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
