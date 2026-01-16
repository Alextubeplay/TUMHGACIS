extends Node3D

#Variables

var plooking = "forward" #forward, left, right, down, up, monitor

func _ready():
	pass # Replace with function body.

func _process(delta):
	
	match [plooking, Input.is_action_just_pressed("Left")]:
		["forward", true]:
			plooking = "left"
			rotate_y(PI / 2)
		
		["up", true]:
			plooking = "left"
			rotate_x(-PI / 4)
			rotate_y(PI / 2)
		
		["down", true]:
			plooking = "left"
			rotate_x(PI / 4)
			rotate_y(PI / 2)
		
		["right", true]:
			plooking = "forward"
			rotate_y(PI / 2)
	
	match [plooking, Input.is_action_just_pressed("Right")]:
		["forward", true]:
			plooking = "right"
			rotate_y(-PI / 2)
		
		["up", true]:
			plooking = "right"
			rotate_x(-PI / 4)
			rotate_y(-PI / 2)
		
		["down", true]:
			plooking = "right"
			rotate_x(PI / 4)
			rotate_y(-PI / 2)
		
		["left", true]:
			plooking = "forward"
			rotate_y(-PI / 2)
	
	match [plooking, Input.is_action_just_pressed("Up")]:
		["forward", true]:
			plooking = "up"
			rotate_x(PI / 4)
		
		["right", true]:
			plooking = "up"
			rotate_y(PI / 2)
			rotate_x(PI / 4)
		
		["down", true]:
			plooking = "forward"
			rotate_x(PI / 4)
		
		["left", true]:
			plooking = "up"
			rotate_y(-PI / 2)
			rotate_x(PI / 4)
	
	match [plooking, Input.is_action_just_pressed("Down")]:
		["forward", true]:
			plooking = "down"
			rotate_x(-PI / 4)
		
		["right", true]:
			plooking = "down"
			rotate_y(PI / 2)
			rotate_x(-PI / 4)
		
		["up", true]:
			plooking = "forward"
			rotate_x(-PI / 4)
		
		["left", true]:
			plooking = "down"
			rotate_y(-PI / 2)
			rotate_x(-PI / 4)
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
