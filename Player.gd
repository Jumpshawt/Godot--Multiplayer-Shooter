extends KinematicBody

#preload the ragdoll scene
var ragdoll_scene = preload("res://Player_ragdoll.tscn")

#variable for when you die to prevent movement
var can_move = true

var jumps = 2

var used_RJ = false

# movement stuff 
const GRAVITY = -24.8
var vert = Vector3()
var accel = 10
var deaccel = 400
var vel = Vector3()
const MAX_SPEED = 20
const JUMP_SPEED = 10
const ACCEL = 4.5

var can_shoot = true

var speed = 20
var direction = Vector3()

const DECEL : float = 8.0
const MAX_SLOPE_ANGLE = 40

var camera
var rotation_helper

var MOUSE_SENSITIVITY = 0.05

# gun stuff
var player_node = null
const DAMAGE = 4
var bullet_scene = preload("CubeStretch.tscn")

var player_deaths = 0
var player_kills = 0 

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
remote func _death(name, id):
	can_move = false
	_player_visiblity(false)
	print(name, " id " ,id)
	
	print(Globals.players[int(id)].name, " killed ", Globals.players[int(name)].name)
	direction -= transform.basis.x
	if id == self.name:
		can_move = false
		$RichTextLabel.visible = true
	$Respawn.start()
##test line plz remove later
#remote func _printshit(lol):

# Called when the node enters the scene tree for the first time.
func _ready():
	var Jump_pad = get_tree().get_root().find_node("Jump_pad", true, false)
	Jump_pad. connect("gordon_is_cringing", self, "_jump_pad")
	var kd_transfer = {player_deaths = 0, player_kills = 0}
#	kd_transfer.player_kills = 0
#	kd_transfer.player_deaths = 0
#	Globals.players[int(self.name)] = kd_transfer
	$"2d/Viewport/2D_World/BG/RichTextLabel".text = self.name
	if is_network_master():
		$MeshInstance.visible = false
		$RichTextLabel2.text = str("your id is #", self.name)
		$"2d".queue_free()
		print("respawn 1 ", Globals.respawn1)
		print("respawn 2 ", Globals.respawn2)
		self.global_transform = Globals.respawn1
		print("network master is", self.name , "and is now located at", self.global_transform.origin)
	else:
		print("not network", self.name)
		print("not master  is", self.name , "and is currently at", self.global_transform.origin)
		self.global_transform = Globals.spawns[1]
		print("not master  is", self.name , "and is now located at", self.global_transform.origin)
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
#		direction = Vector3()
		direction.x = 0
		direction.z = 0
		#process the keybinds
		if Input.is_action_pressed("ui_left"):
			direction -= transform.basis.x
			
		elif Input.is_action_pressed("ui_right"):
			direction += transform.basis.x

		if Input.is_action_pressed("ui_up"):
			direction -= transform.basis.z
		
		elif Input.is_action_pressed("ui_down"):
			direction += transform.basis.z
		if Input.is_action_pressed("zoom"):
			$Rotation_Helper/Camera.fov = 40
		else:
			$Rotation_Helper/Camera.fov = 90
			$rotation
		if Input.is_action_just_pressed("shoot"):
			if can_shoot == true:
				fire_weapon()
		if Input.is_action_just_pressed("Scoreboard"):
			show_score(true)
		if Input.is_action_just_released("Scoreboard"):
			show_score(false)
		
		if Input.is_action_just_pressed("sens_dec"):
			MOUSE_SENSITIVITY -= 0.01
			$Sensitivity.text = str(MOUSE_SENSITIVITY)
		if Input.is_action_just_pressed("sens_inc"):
			MOUSE_SENSITIVITY += 0.01
			$Sensitivity.text = str(MOUSE_SENSITIVITY)
			
		if is_on_floor():
			vert.y = 0
			jumps = 0
			used_RJ = false
			if Input.is_action_pressed("jump"):
				
				print("pressed jump")
				
				vel.y = JUMP_SPEED
				
		else:
			if Input.is_action_just_pressed("jump"):
				if jumps > 0:
					if vel.y > 0:
						vel.y += JUMP_SPEED
						jumps -=1
					if vel.y < 0:
						vel.y = JUMP_SPEED
						jumps -=1
		vel.y += GRAVITY * delta

func process_movement(delta):
	if direction != Vector3() or direction == Vector3():
		if is_network_master():
			if is_on_floor():
				if can_move == true:
					direction.y = 0
					direction = direction.normalized()
					#convert to camera rotation to a normalized vector
					var hvel = vel
					hvel.y = 0 
					var velocity1 = ((sqrt((hvel.x * hvel.x) + (hvel.z * hvel.z))))
					$Speed.text = str(int(velocity1))
#					if abs(hvel.normalized().dot(direction)) < .25 and abs(hvel.normalized().dot(direction)) > 0 and cur_speed > 10:
#						print("strafe")
#						direction = Vector3(cam_vector.y, 0, cam_vector.x)
#						hvel.z = cam_speed.x
#						hvel.x = cam_speed.y 
					
					var target = direction
					target *= speed
					if direction.dot(hvel) > 0:
						
						accel = ACCEL	
					else:
						accel = DECEL
						
						
					hvel = hvel.linear_interpolate(target, accel * delta)
					vel.x = hvel.x 
					vel.z = hvel.z
					vel = move_and_slide(vel, Vector3.UP, true, 4, 0.78, false)
					rpc_unreliable("_set_position", global_transform.origin)
					
			else:
				
				if can_move == true:
					direction.y = 0
					direction = direction.normalized()

					#convert to camera rotation to a normalized vector
					var hvel = vel
					hvel.y = 0 
					var cam_vector = Vector2(cos(rotation.y + 3), sin(rotation.y + 3 )).normalized()
					var velocity1 = ((sqrt((hvel.x * hvel.x) + (hvel.z * hvel.z))))
					var cur_speed = int(((sqrt((hvel.x * hvel.x) + (hvel.z * hvel.z)))))
					var cam_speed = cam_vector * velocity1
					$Speed.text = str(int(velocity1))
					
					if abs(hvel.normalized().dot(direction)) < .5 and abs(hvel.normalized().dot(direction)) > 0 and cur_speed > 10 and hvel.normalized().dot(Vector3(cam_vector.y, 0, cam_vector.x) ) > 0.5:
						direction = lerp(direction, Vector3(cam_vector.y, 0, cam_vector.x), 1)
						hvel.z = cam_speed.x
						hvel.x = cam_speed.y 
					
					var target = direction
					target *= speed * 40
					if direction.dot(hvel) > 0:
						
						accel = ACCEL / 300
					else:
						accel = DECEL / 300
						
					if velocity1 < 40:
						
						hvel = hvel.linear_interpolate(target, accel * delta)
						vel.x = hvel.x 
						vel.z = hvel.z
					else:
						hvel = hvel.linear_interpolate(target, accel * delta)
						vel.x *= 0.9 
						vel.z *= 0.9
					
					vel = move_and_slide(vel, Vector3.UP, true, 4, 0.78, false)
					rpc_unreliable("_set_position", global_transform.origin)
					speed = MAX_SPEED
				
				
				

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

func show_score(gaming):
	if gaming == true:
		$Scoreboard.visible = true
		$Scoreboard.text = ''
		for m in Globals.players:
			print(m)
			print(Globals.players)
			$Scoreboard.text += str(Globals.players[m], "\n")

	else:
		print("hide")
		$Scoreboard.visible = false
	pass

func fire_weapon():
	$AudioStreamPlayer3D.playing = false
	$AudioStreamPlayer3D.playing = true
	if is_network_master():
		$Shoot.start()
		can_shoot = false
		var ray = $Rotation_Helper/Camera/RayCast
		ray.force_raycast_update()
		if ray.is_colliding():
			print("colliding")
			if $Rotation_Helper.rotation_degrees.x < -60:
				if used_RJ == false:
					vel.y += JUMP_SPEED * 3
					print("work")
					used_RJ = true
			var body = ray.get_collider()
			Globals.raycast1_point = ray.get_collision_point()
			Draw_Trail($Rotation_Helper/Camera/scifigun.global_transform, ray.get_collision_point())
			rpc_unreliable("_shoot",$Rotation_Helper/Camera/scifigun.global_transform, ray.get_collision_point())
			
#			clone.scale = Vector3(self.global_transform.origin.distance_to(Globals.raycast1_point))
			
			if body == player_node:
				print("player node")

				pass
			if body.has_method("bullet_hit"):
				player_kills += 1
				 
				print("bullet hit")
				body.bullet_hit(DAMAGE, self.name)
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

remote func _transfer_kd(id, kills, deaths):
	if id == self.name:
		var kd_transfer = {player_kills = 0, player_deaths = 0, name = ''}
		kd_transfer.player_kills = kills
		kd_transfer.player_deaths = deaths
		kd_transfer.name = self.name
		Globals.players[id] = kd_transfer
		print(Globals.players)
		

func bullet_hit(damage, id):
	if is_network_master():
		print("Network maseter")
	if not is_network_master():
		player_deaths += 1
		rpc_unreliable("_transfer_kd", self.name, player_kills, player_deaths)
		print(player_deaths)
		$damage.emitting = true
		print("not Network master")
		var clone = ragdoll_scene.instance()
		var scene_root = get_tree().root.get_children()[0]
		clone.global_transform = self.global_transform
		scene_root.add_child(clone)
		rpc_unreliable("_death", self.name, id)
		_death(self.name, id)
	print(damage)
	print(self.name)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Respawn_timeout():
	can_move = true
	_player_visiblity(true)
	self.global_transform = Globals.spawns[int(rand_range(0,Globals.spawns.size()))]
	rpc_unreliable("_set_position", global_transform.origin)
	pass # Replace with function body.


func _on_Shoot_timeout():
	can_shoot = true
	pass # Replace with function body.


func _jump_pad(body):
	print("jump_pad")
	if body == self:
		print("body entered")
		vel.y = JUMP_SPEED * 5
		pass

func _player_visiblity(state):
	if state == false:
		$MeshInstance.visible = false
		$Rotation_Helper.visible = false
		$Feet_CollisionShape.disabled = true
		$damage.emitting = true
		$RichTextLabel.visible = true
		
	else:
		if is_network_master():
			$MeshInstance.visible = false
		else:
			$MeshInstance.visible = true
		$Rotation_Helper.visible = true
		$damage.emitting = false
		$RichTextLabel.visible = false
		$Feet_CollisionShape.disabled = false
