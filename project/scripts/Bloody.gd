extends Node3D

var timer = 10;

@onready var valve = $"../Valve"
@onready var player = $"../Player"

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if valve.is_opened:
		_go_to_player()
		if timer >0:
			timer -= delta
	else:
		timer = 10;

func _go_to_player():
	if timer <= 0 and player.alive:
		player._die("Bloody")
