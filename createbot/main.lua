local task = require "cbclua.task"
local create = require "mb.create"
local claw = require "claw"
import "config"

function main()
	create.connect()
	claw.init()
	
	startarc(2.3, 19)
	drive:bk{inches=2.4, vel=3}
	first_cleanduck_grab()
end

function startarc(diff, dist)
	drivetrain:drive_dist(10-diff, dist/2, 10, dist/2)
	drivetrain:drive_dist(10, dist/2, 10-diff, dist/2)
end

function first_cleanduck_grab()
	grip_servo(1400)
	claw.down_grab{wait=true}
	claw.close()
	task.sleep(.5)
	claw.lift{wait=true}
end
	
