extends Node

@export var screamer_sound: AudioStream
@export var rage_mode_music: AudioStream

@export_group("Bleach")
@export var bleach_attack_sound: AudioStream
@export var bleach_door_break: AudioStream
@export var bleach_door_open: AudioStream
@export var bleach_nearby: AudioStream

@export_group("Ripper")
@export var ripper_attack_sound: AudioStream
@export var ripper_nearby: AudioStream
@export var ripper_left: AudioStream

@export_group("Hypno")
@export var hypno_attack_sound: AudioStream
@export var hypno_footsteps: AudioStream
@export var hypno_hypnosis: AudioStream

@export_group("Bloody")
@export var bloody_attack_sound: AudioStream
@export var bloody_valve_rip: AudioStream
@export var bloody_valve_hit: AudioStream
@export var bloody_valve_tighten: AudioStream

@onready var audio_player: AudioStreamPlayer = $Attacks
@onready var ambient_player: AudioStreamPlayer = $Ambient

func play_screamer() -> void:
	if audio_player and screamer_sound:
		audio_player.stream = screamer_sound
		audio_player.play()

func play_rage_mode_music() -> void:
	if audio_player and rage_mode_music:
		audio_player.stream = rage_mode_music
		audio_player.play()

func stop_rage_mode_music() -> void:
	if audio_player:
		audio_player.stop()

func play_bloody_attack() -> void:
	if audio_player and bloody_attack_sound:
		audio_player.stream = bloody_attack_sound
		audio_player.play()

func play_hypno_attack() -> void:
	if audio_player and hypno_attack_sound:
		audio_player.stream = hypno_attack_sound
		audio_player.play()

func play_bleach_attack() -> void:
	if audio_player and bleach_attack_sound:
		audio_player.stream = bleach_attack_sound
		audio_player.play()

func play_ripper_attack() -> void:
	if audio_player and ripper_attack_sound:
		audio_player.stream = ripper_attack_sound
		audio_player.play()

func play_bleach_door_break() -> void:
	if audio_player and bleach_door_break:
		audio_player.stream = bleach_door_break
		audio_player.play()

func play_bleach_door_open() -> void:
	if audio_player and bleach_door_open:
		audio_player.stream = bleach_door_open
		audio_player.play()

func play_bleach_nearby() -> void:
	if audio_player and bleach_nearby:
		audio_player.stream = bleach_nearby
		audio_player.play()

func play_ripper_nearby() -> void:
	if audio_player and ripper_nearby:
		audio_player.stream = ripper_nearby
		audio_player.play()

func play_ripper_left() -> void:
	if audio_player and ripper_left:
		audio_player.stream = ripper_left
		audio_player.play()

func play_hypno_footsteps() -> void:
	if audio_player and hypno_footsteps:
		audio_player.stream = hypno_footsteps
		audio_player.play()

func play_hypno_hypnosis() -> void:
	if audio_player and hypno_hypnosis:
		audio_player.stream = hypno_hypnosis
		audio_player.play()

func play_bloody_valve_rip() -> void:
	if audio_player and bloody_valve_rip:
		audio_player.stream = bloody_valve_rip
		audio_player.play()

func play_bloody_valve_hit() -> void:
	if audio_player and bloody_valve_hit:
		audio_player.stream = bloody_valve_hit
		audio_player.play()

func play_bloody_valve_tighten() -> void:
	if audio_player and bloody_valve_tighten:
		audio_player.stream = bloody_valve_tighten
		audio_player.play()

func play_ambient() -> void:
	if ambient_player and not ambient_player.playing:
		ambient_player.play()

func stop_ambient() -> void:
	if ambient_player and ambient_player.playing:
		ambient_player.stop()
