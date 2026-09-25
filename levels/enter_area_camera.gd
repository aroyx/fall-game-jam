extends Area3D

@export var area_pcam: PhantomCamera3D
@export var player_cam: PhantomCamera3D

var initial_camera_position: Vector3
var initial_camera_rotation: Vector3

var tween: Tween
var tween_duration: float = 0.9

func _ready() -> void:
	connect("area_entered", _entered_area)
	connect("area_exited", _exited_area)

func _entered_area(area_3D: Area3D) -> void:
	if area_3D.get_parent() is CharacterBody3D:
		area_pcam.set_priority(40)

func _exited_area(area_3D: Area3D) -> void:
	if area_3D.get_parent() is CharacterBody3D:
		# rotate the player camera
		var current_rot = area_pcam.global_rotation_degrees
		var new_rot = Vector3(current_rot.x, current_rot.y, 0)
		new_rot.x = clampf(new_rot.x, -50.0, 25.0)
		player_cam.set_third_person_rotation_degrees(new_rot)
		area_pcam.set_priority(0)
