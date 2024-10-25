extends Label

func update_speed(speed, min_speed, max_speed):
	# Format the speed to 2 decimal places
	text = "Speed: " + String("%.2f" % speed)
