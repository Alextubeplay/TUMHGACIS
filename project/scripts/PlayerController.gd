extends Node3D

#Variables

var plooking = "forward"
var rotation_direction = Vector3()

#var rotation_speed = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	rotation_direction.x = Input.get_axis("Down", "Up")
	
	match [plooking, rotation_direction.x]:
		
		["forward", 1]:
			plooking = "up"
			rotate_x(PI / 2)
			print("YAY")
			
		["up", -1]:
			plooking = "down"
			rotate_x(PI / 2)
			print("non")
	
	
	#_get_input()
	#transform.basis = Basis(Quaternion.from_euler(rotation_direction))
	#global_rotate(rotation_direction, 0.1)

# _get_input():
	#rotation_direction.x = Input.get_axis("Down", "Up")

	#rotation_direction.y = Input.get_axis("Right", "Left")
	#print(rotation_direction)
