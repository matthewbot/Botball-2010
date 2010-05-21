import "config"
import "drive"

local cbc = require "cbclua.cbc"
local task = require "cbclua.task"
local sweep = require "sweep"
local algorithms = require "algorithms"

-----------

	
function main()
	algorithms.follow_wall_time(2)
	sweep.palms_sweep()
	sweep.palms_retract()
	algorithms.follow_wall_time(5)
	sweep.botguy_sweep()
	sweep.botguy_retract()
	sweep.palms_sweep()
	sweep.palms_retract()
	drive_bk(1,1)
end
