extends Marker2D

@onready var audio_player = $AudioStreamPlayer2D

var flip = false
var rotation_dir = 0.0
		
func _process(delta):
	scale.x = lerp(scale.x,-1.0 if flip else 1.0,delta * 5)
	scale.y = lerp(scale.y,1.0 + sin(Time.get_ticks_msec() * 0.005) * 0.05,delta * 5)
	rotation = lerp(rotation_dir, sin(Time.get_ticks_msec() * 0.005) * 0.5, delta * 5)

func DoTheThing():
	flip = !flip
	if audio_player:
		audio_player.play()
	

func _on_button_pressed():
	DoTheThing()
