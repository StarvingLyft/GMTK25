extends CharacterBody2D

var speed = 300.0
var jump_speed = -500.0
#var is_replaying: bool = false

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

# Get the gravity from the project settings so you can sync with rigid body nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	velocity.y += gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_replaying:
		velocity.y = jump_speed

	# Get the input direction.
	if not is_replaying:
		var input_dir = Input.get_vector("left", "right", "ui_up", "ui_down")
		velocity.x = input_dir.x * speed

	move_and_slide()

func _input(event: InputEvent) -> void:
	# Add controls to start/stop recording and to trigger the replay.
	if event.is_action_pressed("record_toggle"):
		if is_recording:
			stop_recording()
			position = START_POS
			var icons: Array[Node] = get_parent().find_children("","Area2D",false,false)
			for icon in icons:
				icon.get_node("trueIcon").show()
				icon.get_node("qMark").hide()
			await get_tree().create_timer(0.5).timeout
			start_replaying()
		else:
			start_recording()


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
		recorded_inputs.clear()
		is_replaying = false
		is_replaying=false
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
						if is_pressed and is_on_floor():
							velocity.y = jump_speed
					"right":
						velocity.x = speed if is_pressed else 0
					"left":
						velocity.x = -speed if is_pressed else 0
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
	get_node("gandalf").hide()
	get_node("bilbo").show()
	print("Recorded ",recorded_inputs.size() ," events.")

func start_replaying() -> void:
	if recorded_inputs.is_empty():
		print("Nothing to replay!")
		return
	print("--- ▶️ Started Replay ---")
	is_replaying = true
	is_replaying = true
	is_recording = false # Can't replay and record.
	replay_index = 0
	start_time_msec = Time.get_ticks_msec()
	
func dead():
	$bilbo.rotate(-90)
	velocity = Vector2.ZERO
	await get_tree().create_timer(0.5).timeout
	set_collision_mask_value(1,false)
