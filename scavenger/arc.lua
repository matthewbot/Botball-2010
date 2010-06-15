--this is just for fun right now
import "config"

local task = require "cbclua.task"

function arc(speed)
	drivetrain:drive_dist(speed, 3, (speed - 200), 5)
end

function startarc(diff, dist)
	drivetrain:drive_dist(10-diff, dist/2, 10, dist/2)
	drivetrain:drive_dist(10, dist/2, 10-diff, dist/2)
end

function arc_power(power)
	ldrive:mav(-power)
	rdrive:mav(-(power - 200))
end