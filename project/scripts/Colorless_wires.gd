extends Control

var cursor_coordinate = Vector2.ZERO
var retract_value = Vector2.ZERO
var button_center_coordinate = Vector2.ZERO
var button_pressed = false
var wire_retracting = false
var connected_wires = []
var connected_buttons
var max_connected_buttons
var task_done = false

func _ready() -> void:
	max_connected_buttons = $Start_wire.get_child_count()
	
func _process(delta: float) -> void:
	if button_pressed:
		cursor_coordinate = get_local_mouse_position()
		wire_retracting = false
		queue_redraw()
	elif !button_pressed and wire_retracting and cursor_coordinate.distance_to(button_center_coordinate) > 1.0:
		cursor_coordinate = cursor_coordinate.lerp(button_center_coordinate, 2.5 * delta)
		queue_redraw()

func _draw():
	for wire in connected_wires:
		draw_line(wire.start, wire.end, Color(0, 0, 0), 24)
		draw_line(wire.start, wire.end, Color(1, 1, 1), 20)
	
	if (button_pressed or wire_retracting):
		draw_line(button_center_coordinate, cursor_coordinate, Color(0, 0, 0), 24)
		draw_line(button_center_coordinate, cursor_coordinate, Color(1, 1, 1), 20)

func _button_center_getter(button: Button):
	var new_start_pos = button.global_position + button.size / 2 - global_position
	for wire in connected_wires:
		if wire.start == new_start_pos:
			return
	button_center_coordinate = new_start_pos
	button_pressed = true
	wire_retracting = false 
	queue_redraw()

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and button_pressed:
		button_pressed = false
		wire_retracting = true

func _on_wire_start_1_button_pressed() -> void:
	_button_center_getter($Start_wire/wire_start1/wire_start1_button)

func _on_wire_start_2_button_pressed() -> void:
	_button_center_getter($Start_wire/wire_start2/wire_start2_button)

func _on_wire_start_3_button_pressed() -> void:
	_button_center_getter($Start_wire/wire_start3/wire_start3_button)

func _on_wire_start_4_button_pressed() -> void:
	_button_center_getter($Start_wire/wire_start4/wire_start4_button)

func _on_wire_start_5_button_pressed() -> void:
	_button_center_getter($Start_wire/wire_start5/wire_start5_button)

func _on_wire_start_6_button_pressed() -> void:
	_button_center_getter($Start_wire/wire_start6/wire_start6_button)

func _on_right_button_pressed(button: Button):
	if button_pressed:
		var end_pos = button.global_position + button.size / 2 - global_position
		for wire in connected_wires:
			if wire.end == end_pos:
				button_pressed = false
				wire_retracting = true
				queue_redraw()
				return
		connected_wires.append({
			"start": button_center_coordinate,
			"end": end_pos,
			})
		button_pressed = false
		wire_retracting = false
		queue_redraw()
		if connected_wires.size() == max_connected_buttons and not task_done:
			ShiftSettings.completed_tasks += 1
			task_done = true
			print()

func _on_wire_end_1_button_pressed() -> void:
	_on_right_button_pressed($End_wire/wire_end1/wire_end1_button)

func _on_wire_end_2_button_pressed() -> void:
	_on_right_button_pressed($End_wire/wire_end2/wire_end2_button)

func _on_wire_end_3_button_pressed() -> void:
	_on_right_button_pressed($End_wire/wire_end3/wire_end3_button)

func _on_wire_end_4_button_pressed() -> void:
	_on_right_button_pressed($End_wire/wire_end4/wire_end4_button)

func _on_wire_end_5_button_pressed() -> void:
	_on_right_button_pressed($End_wire/wire_end5/wire_end5_button)

func _on_wire_end_6_button_pressed() -> void:
	_on_right_button_pressed($End_wire/wire_end6/wire_end6_button)
