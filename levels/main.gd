extends Node3D

@onready var _player_pcam: PhantomCamera3D = $PlayerCam
@onready var _ceiling_pcam: PhantomCamera3D = $Room1Cam/PhantomCamera3D

@onready var player: CharacterBody3D = $Player
@onready var respawn_point: Marker3D = $RespawnPoint

@export var mouse_sensitivity: float = 0.05

@onready var bgm_slider: HSlider = $UI/MarginContainer/SettingsMenu/Settings/BGM/MarginContainer/Slider
@onready var sfx_slider: HSlider = $UI/MarginContainer/SettingsMenu/Settings/SFX/MarginContainer/Slider
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

@onready var settings_menu: MarginContainer = $UI/MarginContainer/SettingsMenu
@onready var main_menu: VBoxContainer = $UI/MarginContainer/MainMenu
@onready var banana_counter_ui: MarginContainer = $UI/BananaCounter
@onready var game_win_ui: VBoxContainer = $UI/GameWin

@onready var starting_camera: PhantomCamera3D = $StartingCamera
@onready var island: Node3D = $island

func _ready() -> void:
	await get_tree().process_frame
	_player_pcam.set_collision_mask(0)
	for pcam in [_player_pcam, _ceiling_pcam]:
		pcam.tween_started.connect(_on_camera_transition_started)
		pcam.tween_completed.connect(_on_camera_transition_finished)
		pcam.tween_interrupted.connect(_on_camera_transition_finished)
	player.allow_movement = false
	
	bgm_slider.value = clamp(audio_stream_player.volume_linear, 0, 1)
	sfx_slider.value = clamp(player.audio_stream_player_3d.volume_linear, 0, 1)
	
	settings_menu.hide()
	banana_counter_ui.hide()
	game_win_ui.hide()

func _on_camera_transition_started() -> void:
	if is_instance_valid(player):
		player.allow_movement = false

func _on_camera_transition_finished() -> void:
	if is_instance_valid(player):
		player.allow_movement = true

func _process(_delta: float) -> void:
	if player.position.y <= -3:
		player.position = respawn_point.position
		player.playInteractSound()
		
	if Input.is_action_just_pressed("escape") and started:
		if settings_menu.visible:
			_on_back_pressed()
		elif paused:
			resume()
		else:
			pause()
		#island.delete_box1()
	elif Input.is_action_just_pressed("interact") and started and not paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		if not curr_break.is_empty():
			break_shit(curr_break.pop_back())
	
	if Input.is_action_just_pressed("respawn"):
		player.position = respawn_point.position
		player.playInteractSound()

func _unhandled_input(event: InputEvent) -> void:
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	
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

var started = false
var paused = true

func banana_picked_up():
	var index = BananaCounter.captured_bananas
	var icon: TextureRect = get_node_or_null("UI/BananaCounter/BananaCount/ColorRect" + str(index) + "/TextureRect")
	
	if icon:
		icon.show()

func game_win():
	started = false
	pause()
	main_menu.hide()
	game_win_ui.show()
	
	await get_tree().create_timer(3).timeout
	banana_counter_ui.hide()

func _on_start_pressed() -> void:
	if not started:
		started = true
		starting_camera.priority = -1
		player.rotation.y = 0
		banana_counter_ui.show()
	resume()

func pause():
	paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	settings_menu.hide()
	main_menu.show()
	player.allow_movement = false

func resume():
	paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	settings_menu.hide()
	main_menu.hide()
	player.allow_movement = true

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_settings_pressed() -> void:
	settings_menu.show()
	main_menu.hide()

func _on_bgm_slider_value_changed(value: float) -> void:
	audio_stream_player.volume_linear = value

func _on_sfx_slider_value_changed(value: float) -> void:
	player.audio_stream_player_3d.volume_linear = value

func _on_back_pressed() -> void:
	settings_menu.hide()
	main_menu.show()

func _on_quit_on_win_pressed() -> void:
	get_tree().quit()

var banana_scene: PackedScene = preload("res://decor/banana.tscn")

@onready var box_1_marker: Marker3D = $Breakables/Box1/CollisionShape3D/Marker3D
@onready var treausre_1_marker: Marker3D = $Breakables/Treasure1/CollisionShape3D/Marker3D
@onready var treasure_2_marker: Marker3D = $Breakables/Treasure2/CollisionShape3D/Marker3D

var curr_break: Array[String]
var already_broken: Array[String]

func break_shit(item: String):
	if item in already_broken:
		return
	curr_break.erase(item)
	already_broken.append(item)
	var marker: Marker3D
	match item:
		"box_1":
			island.delete_box_1()
			marker = box_1_marker
		"box_2":
			island.delete_box_2()
			return
		"treasure_chest_1":
			island.delete_treasure_chest_1()
			marker = treausre_1_marker
		"treasure_chest_2":
			island.delete_treasure_chest_2()
			marker = treasure_2_marker
	
	await get_tree().process_frame
	var banana: Node3D = banana_scene.instantiate()
	add_child(banana)
	banana.global_position = marker.global_position

# When I changed curr_break's type from String to Array[String] I made AI generate this code to do what I was doing with String
func _add_breakable(item_name: String) -> void:
	if not (item_name in already_broken) and not (item_name in curr_break):
		curr_break.append(item_name)

func _remove_breakable(item_name: String) -> void:
	curr_break.erase(item_name)

func _on_box_1_body_entered(body: Node3D) -> void:
	if body == player:
		_add_breakable("box_1")

func _on_box_1_body_exited(body: Node3D) -> void:
	if body == player:
		_remove_breakable("box_1")

func _on_box_2_body_entered(body: Node3D) -> void:
	if body == player:
		_add_breakable("box_2")

func _on_box_2_body_exited(body: Node3D) -> void:
	if body == player:
		_remove_breakable("box_2")

func _on_treasure_1_body_entered(body: Node3D) -> void:
	if body == player:
		_add_breakable("treasure_chest_1")

func _on_treasure_1_body_exited(body: Node3D) -> void:
	if body == player:
		_remove_breakable("treasure_chest_1")

func _on_treasure_2_body_entered(body: Node3D) -> void:
	if body == player:
		_add_breakable("treasure_chest_2")

func _on_treasure_2_body_exited(body: Node3D) -> void:
	if body == player:
		_remove_breakable("treasure_chest_2")
