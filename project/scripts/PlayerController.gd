extends Node3D

#Variables

var plooking = "forward"
var rotation_direction = Vector3()

func _ready():
	pass # Replace with function body.

func _process(delta):
	
	#match [plooking, Input.action_press("Left")]:
		#["forward", true]:
			#plooking = "left"
			#rotate_y(PI/2)
		#["up", true]:
			#plooking = "left"
			#rotate_x(-PI/4)
			#rotate_y(PI/2)
		#["down", true]:
			#plooking = "left"
			#rotate_x(PI/4)
			#rotate_y(PI/2)
		#_:
			#pass

	#if Input.is_action_just_pressed("Left"):
		#plooking = "left"
		#rotate_y(PI/2)
	#if Input.is_action_just_pressed("Right"):
		#plooking = "right"
		#rotate_y(-PI/2)
	#if Input.is_action_just_pressed("Up"):
		#plooking = "up"
		#rotate_x(PI/4)
	#if Input.is_action_just_pressed("Down"):
		#plooking = "down"
		#rotate_x(-PI/4)
