extends Node3D

@export var START_POS: Vector3
@export var MOVE_SPEED: float = 12.5
@export var KILL_DISTANCE: float = 3.0 
@export var FLOOR_Y: float = 0.0

var chance = 0.8
var bleach_position = "far"
var timer = 25.0
var is_processing_closure = false

@onready var shift_settings = get_node("/root/ShiftSettings")
@onready var crematory = $"../Crematory"
@onready var player = $"../Player"
@onready var bleach_indicator = $"../HUD/BleachNear"
@onready var anim_player = $Bleach2/AnimationPlayer

func _ready() -> void:
	global_position = START_POS
	hide()

func _process(delta: float) -> void:
	if not player.alive: return
	if not shift_settings.is_bleach_active: return
	if not crematory.is_opened:
		if not is_processing_closure:
			is_processing_closure = true
			_check_door_consequence()
		return 
	else:
		is_processing_closure = false
	
	if timer > 0:
		timer -= delta
	_logic()

func _check_door_consequence():
	if bleach_position == "near" or bleach_position == "nearest":
		bleach_position = "far"
		timer = 25.0
		hide()
	elif bleach_position == "far" or bleach_position == "middle":
		if player.alive:
			_mob_kicks_door()
	if bleach_indicator: bleach_indicator.hide()

func _mob_kicks_door():
	await get_tree().create_timer(1.0).timeout
	if not crematory.is_opened:
		crematory.kick_at_player(player.global_position)
		await get_tree().create_timer(0.1).timeout
		show()
		global_position = START_POS
		if anim_player.has_animation("Bleach_jump"):
			anim_player.play("Bleach_jump")
		player._die("BLEACH", self)

func _logic():
	match bleach_position:
		"far":
			if randf() < chance and timer <= 0:
				bleach_position = "middle"
				timer = 25.0
		"middle":
			if randf() < (chance * 0.5) and timer <= 0:
				bleach_position = "near"
				timer = 25.0
		"near":
			if randf() < (chance * 0.25) and timer <= 0:
				bleach_position = "nearest"
				timer = 20.0
		"nearest":
			if bleach_indicator: bleach_indicator.show()
			if timer <= 10.0 and player.alive:
				player._die("BLEACH", self)
				timer = 30.0
