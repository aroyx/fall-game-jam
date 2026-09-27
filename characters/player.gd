extends CharacterBody3D

@export var SPEED: float = 5.0
@export var JUMP_VELOCITY: float = 4.5
@export var _camera: Camera3D

@onready var player_mesh: Node3D = $PlayerMesh
@onready var animation_player: AnimationPlayer = $PlayerMesh/AnimationPlayer

var gravity: float = 9.8
var allow_movement = true
var sprinting = false

func _ready() -> void:
	animation_player.get_animation("walk").loop_mode = Animation.LOOP_LINEAR
	animation_player.get_animation("idle").loop_mode = Animation.LOOP_LINEAR
	animation_player.get_animation("sprint").loop_mode = Animation.LOOP_LINEAR
	animation_player.get_animation("interact-right").loop_mode = Animation.LOOP_NONE

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if allow_movement:
		sprinting = false
		var speed = SPEED
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			audio_stream_player_3d.stream = jump_res
			audio_stream_player_3d.play()
		elif Input.is_action_just_pressed("interact"):
			interact()
		if Input.is_action_pressed("sprint"):
			sprinting = true
			speed = SPEED * 1.5
		
		var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")

		var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			var move_dir: Vector3 = Vector3.ZERO
			move_dir.x = direction.x
			move_dir.z = direction.z
			
			move_dir = move_dir.rotated(Vector3.UP, _camera.rotation.y).normalized()
			velocity.x = move_dir.x * speed
			velocity.z = move_dir.z * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	var horizontal_velocity := Vector2(velocity.x, velocity.z)
	if horizontal_velocity.length_squared() > 0.01:
		var target_angle := atan2(velocity.x, velocity.z)
		player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, target_angle, 10 * delta)
	
	update_animation(horizontal_velocity)
	move_and_slide()

func update_animation(vel: Vector2):
	if animation_player.current_animation == "interact-right" and animation_player.is_playing():
		return
	
	if not is_on_floor():
		animation_player.play("jump", 0.15)
	
	elif vel.length_squared() > 0.01:
		if sprinting:
			animation_player.play("sprint", 0.15)
			walk_sound_effect(true)
		else:
			animation_player.play("walk", 0.15)
			walk_sound_effect()
	else:
		animation_player.play("idle", 0.15)
		
@onready var audio_stream_player_3d: AudioStreamPlayer = $AudioStreamPlayer
@onready var audio_timer: Timer = $AudioStreamPlayer/Timer

const footSteps: Array[Resource] = [
	preload("res://assets/audio/walk/footstep00.ogg"),
	preload("res://assets/audio/walk/footstep01.ogg"),
	preload("res://assets/audio/walk/footstep02.ogg"),
	preload("res://assets/audio/walk/footstep03.ogg"),
	preload("res://assets/audio/walk/footstep04.ogg"),
	preload("res://assets/audio/walk/footstep05.ogg"),
	preload("res://assets/audio/walk/footstep06.ogg"),
	preload("res://assets/audio/walk/footstep07.ogg"),
	preload("res://assets/audio/walk/footstep08.ogg"),
	preload("res://assets/audio/walk/footstep09.ogg")
]

const jump_res = preload("res://assets/audio/jump.wav")
const interact_res = preload("res://assets/audio/interact.wav")

func walk_sound_effect(sprint = false):
	if audio_timer.is_stopped():
		var sound_res = footSteps[randf_range(4, 6)]
		audio_stream_player_3d.stream = sound_res
		audio_stream_player_3d.play()
		if sprint:
			audio_timer.start(0.3)
		else:
			audio_timer.start(0.4)

func interact():
	if not is_on_floor():
		return
	
	allow_movement = false
	animation_player.play("interact-right", 0.15)
	audio_stream_player_3d.stream = interact_res
	audio_stream_player_3d.play()
	await animation_player.animation_finished
	allow_movement = true

func playInteractSound(): # used by main
	audio_stream_player_3d.stream = interact_res
	audio_stream_player_3d.play()
