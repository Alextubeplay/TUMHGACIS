extends CanvasLayer

@onready var hover_exit_zone = find_child("HoverExitZone", true, false)
var player: Node3D = null

func _ready():
	# Ищем игрока через группу "player" (добавь игрока в эту группу в редакторе)
	player = get_tree().get_first_node_in_group("player")
	
	# Если группы нет, можно раскомментировать строку ниже и указать прямой путь:
	# player = get_node_or_null("/root/Main/Player")

	if hover_exit_zone:
		hover_exit_zone.mouse_filter = Control.MOUSE_FILTER_STOP
		if not hover_exit_zone.mouse_entered.is_connected(_on_hover_exit_zone_mouse_entered):
			hover_exit_zone.mouse_entered.connect(_on_hover_exit_zone_mouse_entered)

func _on_hover_exit_zone_mouse_entered():
	# Если монитор открыт и игрок в нем находится — инициируем выход
	if visible and player and player.get("is_monitoring") == true:
		player.exit_monitor()
