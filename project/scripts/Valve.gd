extends Node3D

@onready var shift_settings = ShiftSettings
@onready var valve_indicator = $"../HUD/ValveOpen"
@onready var death_blood = $"../HUD/Death_blood"
@onready var blood_particles: CPUParticles3D = get_node_or_null("Blood_particles")
@onready var blood_sound = get_node_or_null("Blood_sound")

var is_opened = false
var timer = 1.0
var chance = 0.0047
var pushes = 1
var activations = 2

var initial_rage_active = false

func _ready() -> void:
	if shift_settings:
		shift_settings.is_rage_mode_active = false
		shift_settings.rage_triggered_by_valve = false
		shift_settings.rage_timer = 0.0
		initial_rage_active = shift_settings.is_rage_mode_active
		match shift_settings.difficulty:
			1: activations = 2
			2: activations = 4
			3: activations = 100
	if blood_particles:
		blood_particles.emitting = false
	if blood_sound:
		blood_sound.stop()

func _process(delta):
	if !is_opened:
		if timer > 0:
			timer -= delta
		else:
			timer = 1.0
			var is_rage = shift_settings.is_rage_mode_active if shift_settings else false
			var should_open = false
			
			if is_rage:
				should_open = true
			elif activations > 0 and randf() < chance:
				should_open = true
				
			if shift_settings.is_valve_active and should_open:
				is_opened = true
				pushes = randi_range(2, 6)
				if not is_rage:
					activations -= 1
				timer = 30
				trigger_blood_spawning()
	
	if valve_indicator:
		if shift_settings and "hear_loss_mode" in shift_settings and shift_settings.hear_loss_mode and is_opened:
			valve_indicator.show()
		else:
			valve_indicator.hide()

func interact():
	if is_opened:
		close_valve()

func trigger_blood_spawning() -> void:
	await get_tree().create_timer(1.0).timeout
	if is_opened:
		if blood_particles:
			blood_particles.emitting = true
		if blood_sound:
			blood_sound.play()
		if death_blood:
			var tween = create_tween()
			tween.tween_property(death_blood, "color:a", 0.15, 0.5)

func close_valve():
	if is_opened and $AnimationPlayer.current_animation == "":
		if pushes < 1:
			$AnimationPlayer.play("Rotate")
			is_opened = false
			
			if blood_particles:
				blood_particles.emitting = false
				
			if blood_sound:
				blood_sound.stop()
				
			if death_blood:
				var tween = create_tween()
				tween.tween_property(death_blood, "color:a", 0.0, 0.3)
			
			if shift_settings and not initial_rage_active and not shift_settings.rage_triggered_by_valve:
				var diff = shift_settings.difficulty
				var rage_chance = 0.0
				if diff == 2:
					rage_chance = 0.45
				elif diff == 3:
					rage_chance = 0.90
				
				if randf() < rage_chance:
					shift_settings.is_rage_mode_active = true
					shift_settings.rage_triggered_by_valve = true
					shift_settings.rage_timer = 40.0
		else:
			$AnimationPlayer.play("Push")
			pushes -= 1
