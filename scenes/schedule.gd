extends Node  # Attach this to a parent node containing RichTextLabels

@onready var status_label = $"../../../StatusLabel"  # Adjust to your scene
@onready var schedule_label = $"../../../ScheduleLabel"  # Adjust to your scene
var has_schedule = false
var is_ongoing

var schedule = []  # Stores the schedule data

func _ready():
	load_schedule()
	update_display()
	$"../../Timer".timeout.connect(update_display)  # Ensure Timer exists

# Load JSON Data
func load_schedule():
	var file = FileAccess.open("res://asset/data/data.json", FileAccess.READ)
	if file:
		var content = file.get_as_text()
		schedule = JSON.parse_string(content)
		if schedule == null:
			print("❌ JSON parsing failed! Check file format.")
		else:
			print("✅ Schedule loaded successfully!", schedule)
		file.close()
	else:
		print("❌ Error: Failed to load schedule")

# Check if class is ongoing
func is_class_ongoing(start_time: String) -> bool:
	var current_time = Time.get_time_dict_from_system()
	var now_sec = current_time.hour * 3600 + current_time.minute * 60 + current_time.second

	var time_parts = start_time.split(":")
	if time_parts.size() < 3:
		print("⚠️ Invalid time format:", start_time)
		return false

	var hour = int(time_parts[0])
	var minute = int(time_parts[1])
	var second = int(time_parts[2].split(" ")[0])
	var am_pm = time_parts[2].split(" ")[1]

	# Convert to 24-hour format
	if am_pm == "PM" and hour != 12:
		hour += 12
	elif am_pm == "AM" and hour == 12:
		hour = 0

	var class_start_sec = hour * 3600 + minute * 60 + second
	return class_start_sec <= now_sec and now_sec < class_start_sec + 3600

# Function to get the status message
func get_status_message() -> String:
	var current_time = Time.get_time_dict_from_system()
	var now_sec = current_time.hour * 3600 + current_time.minute * 60 + current_time.second
	var today = Time.get_datetime_dict_from_system().weekday  # 0 = Monday, 6 = Sunday
	
	var depart_start = 8 * 3600   # 08:00
	var depart_end = 12 * 3600 + 50 * 60  # 12:50
	var break_start = 15 * 3600 + 30 * 60  # 15:30
	var break_end = 15 * 3600 + 45 * 60  # 15:45
	var home_time = 18 * 3600 + 25 * 60  # 18:25
	
	if today in [1, 2, 3, 4, 5]:  
		if depart_start <= now_sec and now_sec < depart_end:
			return "[center]Berangkat[/center]"
		elif break_start <= now_sec and now_sec <= break_end:
			return "[center]Istirahat![/center]"
		elif now_sec >= home_time:
			return "[center]Saatnya Pulang![/center]"
	elif today in [1, 2, 3, 4, 5, 6]:
		if not (11 * 3600 <= now_sec and now_sec < 18 * 3600) and is_ongoing == true:
			return "[center]Belajar![/center]"
		elif has_schedule and (11 * 3600 <= now_sec and now_sec < 18 * 3600):
			return "[center]Tidak ada kelas[/center]" 
	return "[center]Rebahan~ 😴[/center]"

func convert_to_24_hour_format(time_12h: String) -> String:
	var parts = time_12h.split(":")
	if parts.size() < 3:
		print("⚠️ Invalid time format:", time_12h)
		return ""

	var hour = int(parts[0])
	var minute = parts[1]
	var am_pm = parts[2].split(" ")[1]  # Extract AM/PM

	# Convert to 24-hour format
	if am_pm == "PM" and hour != 12:
		hour += 12
	elif am_pm == "AM" and hour == 12:
		hour = 0

	return "%02d:%s" % [hour, minute]

# Update schedule and status separately
func update_display():
	var today = Time.get_datetime_dict_from_system().weekday
	var days = ["minggu", "senin", "selasa", "rabu", "kamis", "jumat", "sabtu"]

	if today >= days.size():
		schedule_label.text = "[center]Tidak ada jadwal hari ini.[/center]"
		status_label.text = get_status_message()
		return

	var today_name = days[today].to_lower()
	print("🗓️ Today:", today_name)  # Debugging

	var schedule_text = ""
	var ongoing_class = ""
	

	# 🔥 Update status separately
	status_label.text = get_status_message()

	for entry in schedule:
		var entry_day = entry.hari.to_lower()
		if entry_day.strip_edges() == today_name:
			has_schedule = true
			is_ongoing = is_class_ongoing(entry.waktu_masuk)
			var waktu = convert_to_24_hour_format(entry.waktu_masuk)

			if is_ongoing:
				ongoing_class = "[center][color=red]Sedang Berlangsung:[/color]\n%s - %s[/center]\n\n" % [entry.mata_pelajaran, entry.nama_guru]
			schedule_text += "- (%s) %s \n               %s \n" % [waktu, entry.mata_pelajaran, entry.nama_guru]

	# 🔥 Show "Rebahan" only if NO schedule
	if ongoing_class != "":
		schedule_text = ongoing_class + schedule_text
	

	# 🔹 Update only the schedule label
	schedule_label.text = schedule_text
