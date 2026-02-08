extends Node3D

#Variables
var plooking = "forward" #forward, left, right, down, up, monitor
var cooldown = 0.2

@export var valve: Valve
@export var vent: Vent

@onready var o2_bar = $"../HUD/O2_bar"
@onready var o2_percent = $"../HUD/O2_bar_percent"
@onready var placeholder_death = $"../Death_screen/Placeholder_death"

func _ready():
	pass # Replace with function body.

func _process(delta):
	cooldown -= delta
	
	_moving()
	
	_breath(vent.is_opened)

func _moving():
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

func _breath(vent_opened):
	if cooldown <=0:
		if vent_opened:
			o2_bar.value = o2_bar.value + 2.5
			cooldown = 0.2
		else:
			o2_bar.value = o2_bar.value - 0.33
			cooldown = 0.2
	o2_percent.text = str(o2_bar.value) + "%"

func _die(reason):
	placeholder_death.text = "you died of: " + reason
