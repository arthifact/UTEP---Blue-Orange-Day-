extends CharacterBody3D
class_name MovementController

var is_active := false:
	set(val):
		is_active = val
		set_physics_process(is_active)
	get:
		return is_active

# Can't fly below this speed
@export var min_flight_speed = 0
# Maximum airspeed
@export var max_flight_speed = 50
# Turn rate
@export var turn_speed = 1.35
# Climb/dive rate
@export var pitch_speed = 0.95
# Wings "autolevel" speed
@export var level_speed = 3.0
# Throttle change speed
@export var throttle_delta = 50
# Acceleration/deceleration
@export var acceleration = 15.0
@export var deceleration = 20.0  # New: Deceleration rate when no throttle is pressed

# Current speed
var forward_speed = 0
# Throttle input speed
var target_speed = 0
# Lets us change behavior when grounded
var grounded = false

var turn_input = 0
var pitch_input = 0


@onready var mesh = $Striker2
@onready var speedlines = $Speedlines.material
@onready var audio_stream_player_3d = $AudioStreamPlayer3D

func _ready():
	audio_stream_player_3d.play()
	pass

func get_input(delta):
	# Throttle input
	if Input.is_action_pressed("throttle_up"):
		target_speed = min(forward_speed + throttle_delta * delta, max_flight_speed)
	elif Input.is_action_pressed("throttle_down"):
		var limit = 0 if grounded else min_flight_speed
		target_speed = max(forward_speed - throttle_delta * delta, limit)
	else:
		# If no throttle input, reduce speed gradually back to 0
		target_speed = max(forward_speed - deceleration * delta, 0)

	# Turn (roll/yaw) input
	turn_input = Input.get_axis("roll_right", "roll_left")
	if forward_speed <= 0.5:
		turn_input = 0
	
	# Pitch (climb/dive) input
	pitch_input = 0
	if not grounded:
		pitch_input -= Input.get_action_strength("pitch_down")
	if forward_speed >= min_flight_speed:
		pitch_input += Input.get_action_strength("pitch_up")
	pitch_input = Input.get_axis("pitch_down", "pitch_up")

func _physics_process(delta):
	get_input(delta)

	transform.basis = transform.basis.rotated(transform.basis.x.normalized(), pitch_input * pitch_speed * delta)
	transform.basis = transform.basis.rotated(Vector3.UP, turn_input * turn_speed * delta)
	
	# Bank when turning
	if grounded:
		mesh.rotation.z = 0
	else:
		mesh.rotation.z = lerpf(mesh.rotation.z, -turn_input, level_speed * delta)
	
	# Accelerate/decelerate
	forward_speed = lerpf(forward_speed, target_speed, acceleration * delta)
	
	var opacity = forward_speed / 400.0  # 0 to 1 scale
	# Set the opacity of the ColorRect
	speedlines.set_shader_parameter("line_color", Color(1, 1, 1, opacity))
	
	var volume = forward_speed / 500.0  # 0 to 1 scale
	audio_stream_player_3d.volume_db = linear_to_db(volume)
	# Movement is always forward
	velocity = -transform.basis.z * forward_speed
	
	# Landing
	if is_on_floor():
		if not grounded:
			rotation.x = 0
#		velocity.y -= 1
		grounded = true
	else:
		grounded = false
	move_and_slide()
	
	
