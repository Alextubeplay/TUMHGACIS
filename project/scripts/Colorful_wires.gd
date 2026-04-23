extends Control

var cursor_coordinate = Vector2.ZERO
var retract_value = Vector2.ZERO
var button_center_coordinate = Vector2.ZERO
var button_pressed = false
var wire_retracting = false
var wire_color = Color(1, 1, 1)
var connected_buttons
var max_connected_buttons

func coloring():
	
	var base_colors = [
		Color(1, 1, 1),
		Color(0, 0, 0),
		Color("072e77"),
		Color("195ad3")
	]
	
	base_colors.shuffle()
	
	for i in range($Start_wire.get_child_count()):
		$Start_wire.get_child(i).self_modulate = base_colors[i]
		$Start_wire.get_child(i).set_meta("color", base_colors[i])
	
	base_colors.shuffle()
	
	for i in range($End_wire.get_child_count()):
		$End_wire.get_child(i).self_modulate = base_colors[i]
		$End_wire.get_child(i).set_meta("color", base_colors[i])
	
func _ready() -> void:
	max_connected_buttons = $Start_wire.get_child_count
	coloring()
	
	$Start_wire/wire_start1/wire_start1_button.pressed.connect(_button_center_getter.bind($Start_wire/wire_start1/wire_start1_button))
	$Start_wire/wire_start2/wire_start2_button.pressed.connect(_button_center_getter.bind($Start_wire/wire_start2/wire_start2_button))
	$Start_wire/wire_start3/wire_start3_button.pressed.connect(_button_center_getter.bind($Start_wire/wire_start3/wire_start3_button))
	$Start_wire/wire_start4/wire_start4_button.pressed.connect(_button_center_getter.bind($Start_wire/wire_start4/wire_start4_button))
func _process(delta: float) -> void:
	if button_pressed:
		cursor_coordinate = get_local_mouse_position()
		wire_retracting = false
		queue_redraw()
	elif !button_pressed and wire_retracting and cursor_coordinate.distance_to(button_center_coordinate) > 1.0:
		cursor_coordinate = cursor_coordinate.lerp(button_center_coordinate, 2.5 * delta)
		queue_redraw()

func _draw():
	draw_line(button_center_coordinate, cursor_coordinate, Color(0, 0, 0), 24)
	draw_line(button_center_coordinate, cursor_coordinate, wire_color, 20)

func _button_center_getter(button: Button):
	button_center_coordinate = button.global_position + button.size / 2
	button_pressed = true
	wire_color = button.get_parent().get_meta("color")

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		button_pressed = false
		wire_retracting = true


func _on_wire_end_1_button_pressed() -> void:
	pass # Replace with function body.
