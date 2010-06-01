local servoutils = require "mb.servoutils"
import "config"

function init()
	close()
	updown_servo(100)
end

servoutils.build_functions{
	servo = grip_servo,
	open = 1900,
	release_ground = 1300,
	release_basket = 800,
	close = 600
}

servoutils.build_functions{
	servo = updown_servo,
	default_speed = 600,
	up = 1400,
	lifted = 600,
	down = 100,
}
