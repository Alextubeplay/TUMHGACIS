extends Node3D

#Variables
var plooking = "forward" #forward, left, right, down, up, monitor
@export var valve: Valve
@export var vent: Vent
func _ready():
	pass # Replace with function body.

func _process(delta):
	
	match [plooking, Input.is_action_just_pressed("Left")]:
		["forward", true]:
			plooking = "left"
			rotation.y = (PI / 2)
		
		["up", true]:
			plooking = "left"
			rotation.x = (0)
			rotation.y = (PI / 2)
		
		["down", true]:
			plooking = "left"
			rotation.x = (0)
			rotation.y = (PI / 2)
		
		["right", true]:
			plooking = "forward"
			rotation.y = (0)
	
	match [plooking, Input.is_action_just_pressed("Right")]:
		["forward", true]:
			plooking = "right"
			rotation.y = (-PI / 2)
		
		["up", true]:
			plooking = "right"
			rotation.x = (0)
			rotation.y = (-PI / 2)
		
		["down", true]:
			plooking = "right"
			rotation.x = (0)
			rotation.y = (-PI / 2)
		
		["left", true]:
			plooking = "forward"
			rotation.y = (0)
	
	match [plooking, Input.is_action_just_pressed("Up")]:
		["forward", true]:
			plooking = "up"
			rotation.x = (PI / 4)
		
		["right", true]:
			plooking = "up"
			rotation.y = (0)
			rotation.x = (PI / 4)
		
		["down", true]:
			plooking = "forward"
			rotation.x = (0)
		
		["left", true]:
			plooking = "up"
			rotation.y = (0)
			rotation.x = (PI / 4)
	
	match [plooking, Input.is_action_just_pressed("Down")]:
		["forward", true]:
			plooking = "down"
			rotation.x = (-PI / 4)
		
		["right", true]:
			plooking = "down"
			rotation.y = (0)
			rotation.x = (-PI / 4)
		
		["up", true]:
			plooking = "forward"
			rotation.x = (0)
		
		["left", true]:
			plooking = "down"
			rotation.y = (0)
			rotation.x = (-PI / 4)
	
	match [plooking, Input.is_action_just_pressed("Interact")]:
		["left", true]:
			vent.close_vent()
		["up", true]:
			valve.close_valve()
