extends Node3D
class_name Valve

var is_opened = false
var timer = 1
var chance = 0.3 #30%
var pushes = 1;

func _ready():
	pass 

func _process(delta):
	
	if timer >0:
		timer -= delta
		
	if randf() < chance and timer <=0 and !is_opened:
		is_opened = true;
		pushes = randi_range(2, 6)
		timer = 1

func close_valve():
	if is_opened and pushes < 1:
		$AnimationPlayer.play("Rotate")
		is_opened = false
	else:
		$AnimationPlayer.play("Push")
		pushes -= pushes
