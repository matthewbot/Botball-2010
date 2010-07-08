local servoutils = require "mb.servoutils"
local task = require "cbclua.task"
import "config"

function init()
	close()
	up{speed="full"}
end

servoutils.build_functions{
	servo = grip_servo,
	open = 1900,
	release_ground = 1500,
	release_basket = 800,
	close = 600
}

servoutils.build_functions{
	servo = updown_servo,
	default_speed = 1200,
	up = 400,
	lift = 1100,
	down_push = 1480,
	down_release = 1550,
	down_grab = 1900,
}

function up_fling()
	updown_servo(400)
end

function eject()
	launch_motor:fd()
	task.sleep(.2)
	launch_motor:off()
	task.async(function ()
		task.sleep(1)
		launch_motor:bk()
		task.sleep(.1)
		launch_motor:off()
	end)
end


