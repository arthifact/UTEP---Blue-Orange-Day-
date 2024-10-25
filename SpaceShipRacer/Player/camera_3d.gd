extends Camera3D

@export var lerp_speed = 3.0
@export var target_path : NodePath
@export var offset = Vector3.ZERO
@export var min_fov = 70.0  # Minimum FOV
@export var max_fov = 100.0  # Maximum FOV

var target = null

func _ready():
	if target_path:
		target = get_node(target_path)

func _physics_process(delta):
	if !target:
		return

	# Follow target with an offset
	var target_xform = target.global_transform.translated_local(offset)
	global_transform = global_transform.interpolate_with(target_xform, lerp_speed * delta)

	# Keep camera looking at the target
	look_at(target.global_position, target.transform.basis.y)

	# Adjust FOV based on player speed
	var player_speed = target.forward_speed if target.has_method("forward_speed") else 0
	var fov_value = lerp(min_fov, max_fov, player_speed / 45.0)
	fov = fov_value
