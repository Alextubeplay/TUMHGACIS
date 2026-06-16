extends CanvasLayer

@export var player: Node3D

@onready var resume_button: Button = $Menu/Continue
@onready var settings_button: Button = $Menu/Settings
@onready var exit_button: Button = $Menu/Exit

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	
	if not player:
		player = get_tree().get_first_node_in_group("player")
	
	if resume_button: resume_button.pressed.connect(resume_game)
	if settings_button: settings_button.pressed.connect(_on_settings_pressed)
	if exit_button: exit_button.pressed.connect(_on_exit_pressed)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Escape"):
		if get_tree().paused:
			resume_game()
		elif player and player.alive and not player.is_monitoring:
			pause_game()

func pause_game() -> void:
	get_tree().paused = true
	show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func resume_game() -> void:
	get_tree().paused = false
	hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_settings_pressed() -> void:
	pass

func _on_exit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/Main_menu.tscn")
