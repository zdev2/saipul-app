extends RichTextLabel


var timer: Timer

func _ready() -> void:
	# Enable BBCode formatting
	bbcode_enabled = true

	# Create and add a Timer dynamically
	timer = Timer.new()
	timer.wait_time = 1.0
	timer.autostart = true
	timer.one_shot = false
	timer.timeout.connect(_on_timer_timeout)  # Connect timeout signal
	add_child(timer)  # Attach the timer to this node

	update_time()  # Update immediately

func _on_timer_timeout() -> void:
	update_time()  # Update every second

func update_time() -> void:
	var time = Time.get_time_dict_from_system()
	var formatted_time = "[center]%02d:%02d:%02d[/center]" % [time.hour, time.minute, time.second]
	text = formatted_time  # Set text to formatted time
