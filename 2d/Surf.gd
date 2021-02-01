extends Area

#what am i doing with my life 
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal gordon_is_cringing()

export var reset_loc = Vector3(0,0,0)
# Called when the node enters the scene tree for the first time.
func _ready():
	# i hate myself
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Jump_pad_body_entered(body):
	print("cring")
	if body.is_in_group("Player"):
		body.global_transform.origin = reset_loc
		print("i emit signal haha")
		emit_signal("gordon_is_cringing", body)


func _on_Jump_pad_body_exited(body):
	pass # Replace with function body.
