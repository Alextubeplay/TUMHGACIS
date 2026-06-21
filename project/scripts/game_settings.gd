extends Control

@export var window_mode_button: OptionButton
@export var vsync_button: Button
@export var resolution_button: OptionButton

func _ready() -> void:
	_find_nodes_fallback()
	setup_ui()
	update_ui()

func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		if is_node_ready() and is_visible_in_tree():
			update_ui()

func _find_nodes_fallback() -> void:
	if not window_mode_button:
		for name in ["WindowMode", "Window_Mode", "window_mode", "Window Mode", "ScreenMode", "Screen Mode", "Screen_Mode"]:
			var n = find_child(name, true, false)
			if n and n is OptionButton:
				window_mode_button = n
				break
	if not vsync_button:
		for name in ["VSync", "Vsync", "vsync", "V-Sync", "v_sync", "VSyncButton", "VSyncCheckbox"]:
			var n = find_child(name, true, false)
			if n and n is Button:
				vsync_button = n
				break
	if not resolution_button:
		for name in ["Resolution", "resolution", "ResolutionMode", "ResolutionButton"]:
			var n = find_child(name, true, false)
			if n and n is OptionButton:
				resolution_button = n
				break

func setup_ui() -> void:
	if window_mode_button:
		window_mode_button.clear()
		window_mode_button.add_item("Оконный")
		window_mode_button.add_item("Полноэкранный")
		if not window_mode_button.item_selected.is_connected(_on_window_mode_selected):
			window_mode_button.item_selected.connect(_on_window_mode_selected)

	if vsync_button:
		if not vsync_button.toggled.is_connected(_on_vsync_toggled):
			vsync_button.toggled.connect(_on_vsync_toggled)

	if resolution_button:
		resolution_button.clear()
		if "resolutions" in ShiftSettings:
			for res in ShiftSettings.resolutions:
				resolution_button.add_item(str(res.x) + "x" + str(res.y))
		if not resolution_button.item_selected.is_connected(_on_resolution_selected):
			resolution_button.item_selected.connect(_on_resolution_selected)

	var back_btn = find_child("Back", true, false)
	if not back_btn:
		back_btn = find_child("Назад", true, false)
	if back_btn and back_btn is Button:
		if not back_btn.pressed.is_connected(_on_back_pressed):
			back_btn.pressed.connect(_on_back_pressed)

func update_ui() -> void:
	if window_mode_button:
		window_mode_button.set_block_signals(true)
		var wm_val = 0
		if "window_mode" in ShiftSettings:
			wm_val = ShiftSettings.window_mode
		if wm_val == DisplayServer.WINDOW_MODE_WINDOWED or wm_val == 0:
			window_mode_button.selected = 0
		else:
			window_mode_button.selected = 1
		window_mode_button.set_block_signals(false)
			
	if vsync_button:
		vsync_button.set_block_signals(true)
		var vsync_val = false
		if "vsync_enabled" in ShiftSettings:
			vsync_val = ShiftSettings.vsync_enabled
		vsync_button.button_pressed = bool(vsync_val)
		vsync_button.set_block_signals(false)
		
	if resolution_button:
		resolution_button.set_block_signals(true)
		if "resolution_index" in ShiftSettings:
			resolution_button.selected = ShiftSettings.resolution_index
		resolution_button.set_block_signals(false)

func _on_window_mode_selected(index: int) -> void:
	if "window_mode" in ShiftSettings:
		if index == 0:
			ShiftSettings.window_mode = DisplayServer.WINDOW_MODE_WINDOWED
		else:
			ShiftSettings.window_mode = DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN

func _on_vsync_toggled(toggled_on: bool) -> void:
	if "vsync_enabled" in ShiftSettings:
		ShiftSettings.vsync_enabled = toggled_on

func _on_resolution_selected(index: int) -> void:
	if "resolution_index" in ShiftSettings:
		ShiftSettings.resolution_index = index

func _on_back_pressed() -> void:
	hide()
