extends Node3D

#Variables
var rotation_direction = Vector3()
var rotation_speed = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_get_input()
	transform.basis = Basis(Quaternion.from_euler(rotation_direction))
	#global_rotate(rotation_direction, 0.1)

func _get_input():
	rotation_direction.x = Input.get_axis("Down", "Up")

	rotation_direction.y = Input.get_axis("Right", "Left")
	print(rotation_direction)
