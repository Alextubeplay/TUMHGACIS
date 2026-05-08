extends Control

@onready var dangers_list = $HBoxContainer/Dangers/List
@onready var tasks_label = $HBoxContainer/Requirements/Tasks_list
@onready var timer_label = $HBoxContainer/Requirements/Time_list

func _process(_delta):
	_update_information()

func _update_information():
	_update_dangers()
	_update_requirements()

func _update_dangers():
	var active_monsters = []
	
	if ShiftSettings.is_ripper_active:
		active_monsters.append("Ripper is active")
	
	if ShiftSettings.is_valve_active:
		active_monsters.append("Bloody is active")
		
	if ShiftSettings.is_hypno_active:
		active_monsters.append("Hypno is active")
		
	if ShiftSettings.is_bleach_active:
		active_monsters.append("Bleach is active")
	
	if active_monsters.size() > 0:
		dangers_list.text = "\n".join(active_monsters)
	else:
		dangers_list.text = "No active threats"

func _update_requirements():
	var highlight_color = Color("185ad3")
	
	tasks_label.text = "Tasks: " + str(ShiftSettings.completed_tasks) + "/" + str(ShiftSettings.amount_of_tasks)
	if ShiftSettings.completed_tasks >= ShiftSettings.amount_of_tasks:
		tasks_label.modulate = highlight_color
	else:
		tasks_label.modulate = Color.WHITE
		
	if ShiftSettings.is_shift_timer_active:
		timer_label.visible = true
		timer_label.text = "Time Left: " + str(int(ShiftSettings.shift_timer)) + "s"
		if ShiftSettings.shift_timer <= 0:
			timer_label.modulate = highlight_color
		else:
			timer_label.modulate = Color.WHITE
	else:
		timer_label.visible = false
