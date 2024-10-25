extends Node

@onready var check_points = $"../CheckPoints"  # Adjust based on your actual node structure
@onready var laptime = $"../UI/PanelContainer/laptime"

var total_checkpoints: int = 0
var current_checkpoint: int = 0
var lap_complete: bool = false
var checkpoints_dict = {}

var timer_started: bool = false
var start_time: float = 0.0
var elapsed_time: float = 0.0

func _ready() -> void:
	lap_complete = false
	current_checkpoint = 0
	checkpoints_dict = {}
	
	# Connect all checkpoints to the signal and store them in the dictionary
	for checkpoint in check_points.get_children():
		checkpoint.connect("checkpoint_passed", Callable(self, "_on_checkpoint_passed"))
		print("Connected to", checkpoint.name)
		checkpoints_dict[checkpoint.checkpoint_id] = checkpoint
	
	total_checkpoints = checkpoints_dict.size()
	print("Total checkpoints:", total_checkpoints)
	

func _on_checkpoint_passed(checkpoint_id: int) -> void:
	if checkpoint_id == current_checkpoint:
		print("Checkpoint", checkpoint_id, "correctly passed!")
		if current_checkpoint == 0 and not timer_started:
			_start_timer()
		current_checkpoint += 1

		if current_checkpoint == total_checkpoints:
			lap_complete = true
			print("Lap complete!")
			_stop_timer()
			print("Elapsed time: ", elapsed_time, "s")
			# Reset for a new lap if needed
			_reset_checkpoints()
		else:
			_set_next_checkpoint_visible()  # Show the next required checkpoint
	else:
		print("Incorrect checkpoint! Please return to checkpoint", current_checkpoint)
		_set_next_checkpoint_visible()

func _set_next_checkpoint_visible() -> void:
	for id in checkpoints_dict:
		if id == current_checkpoint:
			checkpoints_dict[id]._set_visible(true)  # Show the next checkpoint
		else:
			checkpoints_dict[id]._set_visible(false)  # Hide other checkpoints

func _start_timer():
	timer_started = true
	start_time = Time.get_ticks_msec() / 1000.0  # Use Time instead of OS
	print("Timer started at", start_time)

func _stop_timer():
	elapsed_time = (Time.get_ticks_msec() / 1000.0) - start_time
	timer_started = false
	print("Timer stopped at", elapsed_time, "s")
	laptime.text = "%.2f s" % elapsed_time  # Update the lap time label

func _process(delta):
	if timer_started:
		elapsed_time = (Time.get_ticks_msec() / 1000.0) - start_time
		laptime.text = "%.2f s" % elapsed_time

func _reset_checkpoints() -> void:
	for id in checkpoints_dict:
		checkpoints_dict[id]._set_visible(false)  # Hide all checkpoints

	# Reset state and show the first checkpoint for a new lap
	current_checkpoint = 0
	lap_complete = false
	timer_started = false
	start_time = 0.0
	elapsed_time = 0.0
	#laptime.text = "Time: 0.00 seconds"
	print("Checkpoints reset, ready for the next lap.")
	checkpoints_dict[current_checkpoint]._set_visible(true)  # Show the first checkpoint
