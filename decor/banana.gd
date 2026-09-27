extends Node3D

var in_range = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and in_range:
		pickup_banana()

func pickup_banana():
	queue_free()
	BananaCounter.pickupBanana()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		in_range = true

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		in_range = false
