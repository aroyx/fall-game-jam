extends Node3D

@onready var _player_pcam: PhantomCamera3D = $PlayerCam
@onready var _ceiling_pcam: PhantomCamera3D = $Room1Cam/PhantomCamera3D

@onready var player: CharacterBody3D = $Player

@export var mouse_sensitivity: float = 0.05

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	await get_tree().process_frame
	
	for pcam in [_player_pcam, _ceiling_pcam]:
		pcam.tween_started.connect(_on_camera_transition_started)
		pcam.tween_completed.connect(_on_camera_transition_finished)
		pcam.tween_interrupted.connect(_on_camera_transition_finished)

func _on_camera_transition_started() -> void:
	if is_instance_valid(player):
		player.allow_movement = false

func _on_camera_transition_finished() -> void:
	if is_instance_valid(player):
		player.allow_movement = true


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("escape"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _unhandled_input(event: InputEvent) -> void:
	if _player_pcam.get_follow_mode() == _player_pcam.FollowMode.THIRD_PERSON:
		_set_pcam_rotation(_player_pcam, event)

func _set_pcam_rotation(pcam: PhantomCamera3D, event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var pcam_rotation_degrees: Vector3
		pcam_rotation_degrees = pcam.get_third_person_rotation_degrees()
		pcam_rotation_degrees.x -= event.relative.y * mouse_sensitivity
		pcam_rotation_degrees.x = clampf(pcam_rotation_degrees.x, -50.0, 25.0)
		pcam_rotation_degrees.y -= event.relative.x * mouse_sensitivity
		pcam_rotation_degrees.y = wrapf(pcam_rotation_degrees.y, 0, 360)
		pcam.set_third_person_rotation_degrees(pcam_rotation_degrees)
