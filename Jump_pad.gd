extends Area

#what am i doing with my life 
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal gordon_is_cringing()

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
		print("i emit signal haha")
		emit_signal("gordon_is_cringing", body)


func _on_Jump_pad_body_exited(body):
	pass # Replace with function body.
