extends VBoxContainer

@onready var screen_mode_button = get_node_or_null("PanelContainer/VBoxContainer/TabContainer/Graphics/ScrollContainer/VBoxContainer/Screen_mode/OptionButton")
@onready var resolution_button = get_node_or_null("PanelContainer/VBoxContainer/TabContainer/Graphics/ScrollContainer/VBoxContainer/Resolution/OptionButton")
@onready var vsync_button = get_node_or_null("PanelContainer/VBoxContainer/TabContainer/Graphics/ScrollContainer/VBoxContainer/V-sync/CheckButton")
@onready var graphics_reset_button = get_node_or_null("PanelContainer/VBoxContainer/TabContainer/Graphics/ScrollContainer/VBoxContainer/Rest/Button")
@onready var master_slider = get_node_or_null("PanelContainer/VBoxContainer/TabContainer/Sound/ScrollContainer/VBoxContainer/Master/HSlider")
@onready var music_slider = get_node_or_null("PanelContainer/VBoxContainer/TabContainer/Sound/ScrollContainer/VBoxContainer/Music/HSlider")
@onready var sounds_slider = get_node_or_null("PanelContainer/VBoxContainer/TabContainer/Sound/ScrollContainer/VBoxContainer/Sounds/HSlider")
@onready var sound_reset_button = get_node_or_null("PanelContainer/VBoxContainer/TabContainer/Sound/ScrollContainer/VBoxContainer/Rest/Button")
@onready var mouse_sens_slider = get_node_or_null("PanelContainer/VBoxContainer/TabContainer/Game/ScrollContainer/VBoxContainer/Mouse_sensetivity/HSlider")
@onready var hear_loss_button = get_node_or_null("PanelContainer/VBoxContainer/TabContainer/Game/ScrollContainer/VBoxContainer/Hear_loss_mode/CheckButton")
@onready var endless_button = get_node_or_null("PanelContainer/VBoxContainer/TabContainer/Game/ScrollContainer/VBoxContainer/Endless_mode/CheckButton")
@onready var language_button = get_node_or_null("PanelContainer/VBoxContainer/TabContainer/Game/ScrollContainer/VBoxContainer/Language/OptionButton")
@onready var game_reset_button = get_node_or_null("PanelContainer/VBoxContainer/TabContainer/Game/ScrollContainer/VBoxContainer/Rest/Button")
@onready var back_button = get_node_or_null("Back")

func _ready() -> void:
	setup_signals()
	update_ui()

func setup_signals() -> void:
	if screen_mode_button:
		screen_mode_button.item_selected.connect(_on_screen_mode_selected)
	if resolution_button:
		resolution_button.item_selected.connect(_on_resolution_selected)
	if vsync_button:
		vsync_button.toggled.connect(_on_vsync_toggled)
	if graphics_reset_button:
		graphics_reset_button.pressed.connect(_on_graphics_reset_pressed)
	if master_slider:
		master_slider.value_changed.connect(_on_master_slider_changed)
	if music_slider:
		music_slider.value_changed.connect(_on_music_slider_changed)
	if sounds_slider:
		sounds_slider.value_changed.connect(_on_sounds_slider_changed)
	if sound_reset_button:
		sound_reset_button.pressed.connect(_on_sound_reset_pressed)
	if mouse_sens_slider:
		mouse_sens_slider.value_changed.connect(_on_mouse_sens_changed)
	if hear_loss_button:
		hear_loss_button.toggled.connect(_on_hear_loss_toggled)
	if endless_button:
		endless_button.toggled.connect(_on_endless_toggled)
	if language_button:
		language_button.item_selected.connect(_on_language_selected)
	if game_reset_button:
		game_reset_button.pressed.connect(_on_game_reset_pressed)
	if back_button:
		back_button.pressed.connect(_on_back_pressed)

func update_ui() -> void:
	if not ShiftSettings:
		return
		
	var tab_container = get_node_or_null("PanelContainer/VBoxContainer/TabContainer")
	if tab_container:
		tab_container.set_tab_title(0, tr("TAB_GRAPHICS"))
		tab_container.set_tab_title(1, tr("TAB_SOUND"))
		tab_container.set_tab_title(2, tr("TAB_GAME"))
		
	if screen_mode_button and "window_mode" in ShiftSettings:
		screen_mode_button.set_block_signals(true)
		var current_index = screen_mode_button.selected
		screen_mode_button.clear()
		screen_mode_button.add_item(tr("SCREEN_WINDOWED"))
		screen_mode_button.add_item(tr("SCREEN_FULLSCREEN"))
		if current_index != -1:
			screen_mode_button.selected = current_index
		else:
			if ShiftSettings.window_mode == DisplayServer.WINDOW_MODE_WINDOWED:
				screen_mode_button.selected = 0
			else:
				screen_mode_button.selected = 1
		screen_mode_button.set_block_signals(false)
		
	if resolution_button and "resolution_index" in ShiftSettings:
		resolution_button.set_block_signals(true)
		resolution_button.selected = ShiftSettings.resolution_index
		resolution_button.set_block_signals(false)
	if vsync_button and "vsync_enabled" in ShiftSettings:
		vsync_button.set_block_signals(true)
		vsync_button.button_pressed = ShiftSettings.vsync_enabled
		vsync_button.set_block_signals(false)
	if master_slider and "master_volume" in ShiftSettings:
		master_slider.set_block_signals(true)
		master_slider.value = ShiftSettings.master_volume
		master_slider.set_block_signals(false)
	if music_slider and "music_volume" in ShiftSettings:
		music_slider.set_block_signals(true)
		music_slider.value = ShiftSettings.music_volume
		music_slider.set_block_signals(false)
	if sounds_slider and "sounds_volume" in ShiftSettings:
		sounds_slider.set_block_signals(true)
		sounds_slider.value = ShiftSettings.sounds_volume
		sounds_slider.set_block_signals(false)
	if mouse_sens_slider and "mouse_sensitivity" in ShiftSettings:
		mouse_sens_slider.set_block_signals(true)
		mouse_sens_slider.value = ShiftSettings.mouse_sensitivity
		mouse_sens_slider.set_block_signals(false)
	if hear_loss_button and "hear_loss_mode" in ShiftSettings:
		hear_loss_button.set_block_signals(true)
		hear_loss_button.button_pressed = ShiftSettings.hear_loss_mode
		hear_loss_button.set_block_signals(false)
	if endless_button and "endless_mode" in ShiftSettings:
		endless_button.set_block_signals(true)
		endless_button.button_pressed = ShiftSettings.endless_mode
		endless_button.set_block_signals(false)
	if language_button and "language_index" in ShiftSettings:
		language_button.set_block_signals(true)
		language_button.selected = ShiftSettings.language_index
		language_button.set_block_signals(false)

func _on_screen_mode_selected(index: int) -> void:
	if "window_mode" in ShiftSettings:
		if index == 0:
			ShiftSettings.window_mode = DisplayServer.WINDOW_MODE_WINDOWED
		else:
			ShiftSettings.window_mode = DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN

func _on_resolution_selected(index: int) -> void:
	if "resolution_index" in ShiftSettings:
		ShiftSettings.resolution_index = index

func _on_vsync_toggled(toggled_on: bool) -> void:
	if "vsync_enabled" in ShiftSettings:
		ShiftSettings.vsync_enabled = toggled_on

func _on_graphics_reset_pressed() -> void:
	ShiftSettings.reset_graphics()
	update_ui()

func _on_sound_reset_pressed() -> void:
	ShiftSettings.reset_audio()
	update_ui()

func _on_game_reset_pressed() -> void:
	ShiftSettings.reset_gameplay()
	update_ui()

func _on_master_slider_changed(value: float) -> void:
	if "master_volume" in ShiftSettings:
		ShiftSettings.master_volume = value

func _on_music_slider_changed(value: float) -> void:
	if "music_volume" in ShiftSettings:
		ShiftSettings.music_volume = value

func _on_sounds_slider_changed(value: float) -> void:
	if "sounds_volume" in ShiftSettings:
		ShiftSettings.sounds_volume = value

func _on_mouse_sens_changed(value: float) -> void:
	if "mouse_sensitivity" in ShiftSettings:
		ShiftSettings.mouse_sensitivity = value

func _on_hear_loss_toggled(toggled_on: bool) -> void:
	if "hear_loss_mode" in ShiftSettings:
		ShiftSettings.hear_loss_mode = toggled_on

func _on_endless_toggled(toggled_on: bool) -> void:
	if "endless_mode" in ShiftSettings:
		ShiftSettings.endless_mode = toggled_on

func _on_language_selected(index: int) -> void:
	if "language_index" in ShiftSettings:
		ShiftSettings.language_index = index
		if index == 0:
			TranslationServer.set_locale("en")
		elif index == 1:
			TranslationServer.set_locale("ru")
		update_ui()

func _on_back_pressed() -> void:
	var main_menu = get_tree().current_scene
	if main_menu and main_menu.has_method("_on_settings_back_pressed"):
		main_menu._on_settings_back_pressed()
