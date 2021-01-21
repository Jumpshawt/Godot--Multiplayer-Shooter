extends KinematicBody

#preload the ragdoll scene
var ragdoll_scene = preload("res://Player_ragdoll.tscn")

#variable for when you die to prevent movement
var can_move = true

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
var bullet_scene = preload("CubeStretch.tscn")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

remote func _shoot(Pos1, Pos2):
	Draw_Trail(Pos1, Pos2)
	pass


#set position is called by the client
remote func _set_position(pos):
	global_transform.origin = pos

remote func _set_rotation(rot_x, rot_y):
	$Rotation_Helper.rotation_degrees = rot_x
	self.rotation_degrees = rot_y
	
#death
remote func _death(name):
	can_move = false
	_player_visiblity(false)
	print(name)
	direction -= transform.basis.x
	if name == self.name:
		can_move = false
		$RichTextLabel.visible = true
		print("death")
	$Respawn.start()
##test line plz remove later
#remote func _printshit(lol):

# Called when the node enters the scene tree for the first time.
func _ready():
	
	if is_network_master():
		print("network master is", self.name)
		self.global_transform = Globals.respawn1
	else:
		print("not network", self.name)
		self.global_transform = Globals.respawn1
#		rpc_unreliable("_set_position", global_transform.origin)
#		move_and_slide(global_transform.origin)
		
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
	direction -= transform.basis.x
	pass # Replace with function body.

func _physics_process(delta):
	process_input(delta)
	process_movement(delta)
	

func process_input(delta):
	
	if can_move == true:
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
		if Input.is_action_just_pressed("shoot"):
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
			if can_move == true:
				move_and_slide(vert + direction * speed, Vector3.UP)
				rpc_unreliable("_set_position", global_transform.origin)
		

#processes mouse rotation shit
func _input(event):
	
	if is_network_master():
		if Input.is_action_just_pressed("ui_cancel"):
			print("pressed esc")
			if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			rotation_helper.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY * -1))
			self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))
			var camera_rot = rotation_helper.rotation_degrees
			camera_rot.x = clamp(camera_rot.x, -70, 70)
			if is_network_master():
				rotation_helper.rotation_degrees = camera_rot
			rpc_unreliable("_set_rotation", rotation_helper.rotation_degrees, self.rotation_degrees)

	


func fire_weapon():
	if is_network_master():
		var ray = $Rotation_Helper/Camera/RayCast
		ray.force_raycast_update()
		if ray.is_colliding():
			print("colliding")
			var body = ray.get_collider()
			Globals.raycast1_point = ray.get_collision_point()
			Draw_Trail($Rotation_Helper/Camera/scifigun.global_transform, ray.get_collision_point())
			rpc_unreliable("_shoot",$Rotation_Helper/Camera/scifigun.global_transform, ray.get_collision_point())
			
#			clone.scale = Vector3(self.global_transform.origin.distance_to(Globals.raycast1_point))
			
			if body == player_node:
				print("player node")

				pass
			if body.has_method("bullet_hit"):
				print("bullet hit")
				body.bullet_hit(DAMAGE)
		else:
			print("not")
		pass


func Draw_Trail(Pos1, Pos2):
	if is_network_master():
		print("is not master network and the two positions are ", Pos1, Pos2)
	var clone = bullet_scene.instance()
	var scene_root = get_tree().root.get_children()[0]
	clone.global_transform = Pos1
	clone.look_at1 = Pos2
	scene_root.add_child(clone)



func bullet_hit(damage):
	if is_network_master():
		print("Network maseter")
	if not is_network_master():
		$damage.emitting = true
		print("not Network master")
		var clone = ragdoll_scene.instance()
		var scene_root = get_tree().root.get_children()[0]
		clone.global_transform = self.global_transform
		scene_root.add_child(clone)
		rpc_unreliable("_death", self.name)
		_death("lol")

		
	
	print(damage)
	print(self.name)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Respawn_timeout():
	can_move = true
	_player_visiblity(true)
	
	self.global_transform = Globals.respawn1
	rpc_unreliable("_set_position", global_transform.origin)
	pass # Replace with function body.

func _player_visiblity(state):
	if state == false:
		$MeshInstance.visible = false
		$Rotation_Helper/Camera/scifigun/scifi.visible = false
		$damage.emitting = true
	else:
		$MeshInstance.visible = true
		$Rotation_Helper/Camera/scifigun/scifi.visible = true
		$damage.emitting = false
