local servoutils = require "mb.servoutils"
import "config"

function init()
	close()
	up{speed="full"}
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
	default_speed = 1200,
	up = 400,
	lift = 750,
	down = 1500,
	down_grab = 1900,
}

function up_fling()
	updown_servo(400)
end

