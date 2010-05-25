import "config"

local cbc = require "cbclua.cbc"
local task = require "cbclua.task"
local arm = require "arm"
local algorithms = require "algorithms"
local sweep = require "sweep"

-----------

	
function main()
	sweep.palms_sweep()
	sweep.palms_retract()
	algorithms.follow_wall_sensor()
	algorithms.final_palm_lineup()
	sweep.palms_sweep()
	sweep.palms_retract()
end
