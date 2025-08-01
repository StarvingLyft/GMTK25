extends Node2D

# 1. --- VARIABLES ---
# The actions you want to track. Make sure these exist in your Input Map.
const MONITORED_ACTIONS: Array[String] = ["jump", "left", "right"]
const START_POS = Vector2(50,480)

# This array will store our recorded input data.
var recorded_inputs: Array = []

# State management variables.
var is_recording: bool = false
var is_replaying: bool = false

# Used to calculate the elapsed time for recording/replaying.
var start_time_msec: int = 0
# Index for tracking which event to play back next.
var replay_index: int = 0


# 2. --- INPUT HANDLING & RECORDING ---
# _input is great for capturing the exact moment an event happens.
func _input(event: InputEvent) -> void:
	# Add controls to start/stop recording and to trigger the replay.
	if event.is_action_pressed("record_toggle"):
		if is_recording:
			stop_recording()
			$player.position = START_POS
		else:
			start_recording()
	
	if event.is_action_pressed("replay"):
		start_replaying()

	# --- Recording Logic ---
	if not is_recording or is_replaying:
		return # Only record if is_recording is true and we're not replaying.

	# Check if the current input event matches one of our monitored actions.
	for action in MONITORED_ACTIONS:
		if event.is_action_pressed(action) or event.is_action_released(action):
			var new_event: Dictionary = {
				"time_msec": Time.get_ticks_msec() - start_time_msec,
				"action": action,
				"pressed": event.is_action_pressed(action)
			}
			recorded_inputs.append(new_event)
			# No need to check other actions for this same event.
			break


# 3. --- REPLAY LOGIC ---
# _process runs every frame, perfect for time-based playback.
func _process(delta: float) -> void:
	if not is_replaying:
		return

	# If we've played all the events, stop.
	if replay_index >= recorded_inputs.size():
		print("--- Replay Finished ---")
		is_replaying = false
		$player.is_replaying=false
		return

	# Calculate how much time has passed since the replay started.
	var elapsed_time: int = Time.get_ticks_msec() - start_time_msec

	# Check the next event in the recording.
	var next_event: Dictionary = recorded_inputs[replay_index]
	
	# If enough time has passed to trigger this event...
	if elapsed_time >= next_event.time_msec:
		var action: String = next_event.action
		var is_pressed: bool = next_event.pressed

		# Simulate the input action using Godot's Input singleton.
		#if is_pressed:
			#Input.action_press(action)
			#print("Replaying: PRESS ",action)
		#else:
			#Input.action_release(action)
			#print("Replaying: RELEASE ",action)
		print("Replaying: PRESS ",action)
		match action:
					"jump":
						if is_pressed and $player.is_on_floor():
							$player.velocity.y = $player.jump_speed
					"right":
						$player.velocity.x = $player.speed if is_pressed else 0
					"left":
						$player.velocity.x = -$player.speed if is_pressed else 0
		print("Replaying: RELEASE ",action)
		# Move to the next event for the next frame.
		replay_index += 1


# 4. --- CONTROL FUNCTIONS ---
func start_recording() -> void:
	print("--- 🔴 Started Recording ---")
	is_recording = true
	is_replaying = false # Can't record and replay at the same time.
	recorded_inputs.clear() # Clear any previous recording.
	start_time_msec = Time.get_ticks_msec()

func stop_recording() -> void:
	print("--- ⏹️ Stopped Recording ---")
	is_recording = false
	get_node("player/gandalf").hide()
	get_node("player/bilbo").show()
	print("Recorded ",recorded_inputs.size() ," events.")

func start_replaying() -> void:
	if recorded_inputs.is_empty():
		print("Nothing to replay!")
		return
	print("--- ▶️ Started Replay ---")
	is_replaying = true
	$player.is_replaying = true
	is_recording = false # Can't replay and record.
	replay_index = 0
	start_time_msec = Time.get_ticks_msec()
