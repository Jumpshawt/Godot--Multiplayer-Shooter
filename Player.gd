extends KinematicBody

# movement stuff 
const GRAVITY = -24.8
var vert = Vector3()

var vel = Vector3()
const MAX_SPEED = 20
const JUMP_SPEED = 18
const ACCEL = 4.5


var speed = 5
var direction = Vector3()

const DEACCEL= 16
const MAX_SLOPE_ANGLE = 40

var camera
var rotation_helper

var MOUSE_SENSITIVITY = 0.05

# gun stuff
var player_node = null
const DAMAGE = 4

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


#set position is called by the client
remote func _set_position(pos):
	global_transform.origin = pos
remote func _set_rotation(rot_x, rot_y):
	
	$Rotation_Helper.rotation_degrees = rot_x
	self.rotation_degrees = rot_y
	
##test line plz remove later
#remote func _printshit(lol):
#	print("lolepic")

# Called when the node enters the scene tree for the first time.
func _ready():
	direction.y = -.1
	camera = $Rotation_Helper/Camera
	rotation_helper = $Rotation_Helper
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	print('test')
	if !is_network_master():
		print('rotate helper master true')
		$Rotation_Helper/Camera.current = false
	else:
		$Rotation_Helper/Camera.current = true
		print('rotate helper master false')
	pass # Replace with function body.

func _physics_process(delta):
	process_input(delta)
	process_movement(delta)
	

func process_input(delta):
	
	direction = Vector3()
	
	#process the keybinds
	if Input.is_action_pressed("ui_left"):
		direction -= transform.basis.x
		
	elif Input.is_action_pressed("ui_right"):
		direction += transform.basis.x
	
	if Input.is_action_pressed("ui_up"):
		direction -= transform.basis.z
	elif Input.is_action_pressed("ui_down"):
		direction += transform.basis.z
	if Input.is_action_pressed("shoot"):
		fire_weapon()
		
	direction = direction.normalized()
	
	#jumping
	
	
	if is_on_floor():
		vert.y = 0
		if Input.is_action_just_pressed("jump"):
			print("pressed jump")
			vert.y = JUMP_SPEED
			direction += transform.basis.x
	
#	print("not on floor")
	vert.y += GRAVITY * delta

func process_movement(delta):
	if direction != Vector3() or not is_on_floor():
		if is_network_master():
			move_and_slide(vert + direction * speed, Vector3.UP)
			
			rpc_unreliable("_set_position", global_transform.origin)
		

#processes mouse rotation shit
func _input(event):
	
	if is_network_master():
		if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			rotation_helper.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY * -1))
			self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))
	
			var camera_rot = rotation_helper.rotation_degrees
			camera_rot.x = clamp(camera_rot.x, -70, 70)
			if is_network_master():
				rotation_helper.rotation_degrees = camera_rot
			rpc_unreliable("_set_rotation", rotation_helper.rotation_degrees, self.rotation_degrees)
	


func fire_weapon():
	print("lol")
	var ray = $Rotation_Helper/Camera/RayCast
	ray.force_raycast_update()
	if ray.is_colliding():
		var body = ray.get_collider()
		
		if body == player_node:
			pass
		elif body.has_method("bullet_hit"):
			body.bullet_hit(DAMAGE, ray.global_transform)
	
	pass

func bullet_hit(damage):
	print("lol")
	print(damage)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
