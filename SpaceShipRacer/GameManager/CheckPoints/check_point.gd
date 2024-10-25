extends Area3D 

@export var checkpoint_id: int = 0
signal checkpoint_passed(checkpoint_id)

@onready var mesh = $MeshInstance3D
@onready var audio_player = $AudioStreamPlayer3D

func _ready() -> void:
	if not mesh:
		push_error("Mesh is null. Please check the node path.")
		return

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		play_first_035_seconds()
		print("Checkpoint", checkpoint_id, "passed by", body.name)
		emit_signal("checkpoint_passed", checkpoint_id)
	else:
		print("Failed at checkpoint", checkpoint_id, "by", body.name)

func _set_visible(is_visible: bool) -> void:
	if not mesh:
		push_error("Mesh is null in _set_visible. Please check the node path.")
		return
	mesh.visible = is_visible

func play_first_035_seconds():
	# Ensure the audio has a stream loaded
	if audio_player.stream:
		# Start playing from the beginning
		audio_player.play(0.0)

		# Set up a timer to stop the audio after 0.35 seconds
		var timer = Timer.new()
		timer.wait_time = 0.5
		timer.one_shot = true
		add_child(timer)
		timer.connect("timeout", Callable(self, "_on_timer_timeout"))
		timer.start()

func _on_timer_timeout():
	audio_player.stop()  # Stop the audio playback
