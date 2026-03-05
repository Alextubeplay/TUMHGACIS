extends Node3D
class_name Valve

var is_opened = false
var timer = 1
var chance = 1.0047 #0.47%
var pushes = 1;
var activations = 2;

@onready var death = $"../Death_screen/Placeholder_death"

func _ready():
	pass 

func _process(delta):
	
	if !is_opened:
		if timer > 0:
			timer -= delta
		else:
			timer = 1;
	
	if randf() < chance and timer <=0 and !is_opened and activations > 0:
		is_opened = true;
		pushes = randi_range(2, 6)
		activations -= 1
		timer = 30



func close_valve():
	if is_opened and $AnimationPlayer.current_animation == "":
		
		if pushes < 1:
			$AnimationPlayer.play("Rotate")
			is_opened = false
			
		else:
			$AnimationPlayer.play("Push")
			pushes -= 1
