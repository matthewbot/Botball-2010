import "config"
import "drive"

local cbc = require "cbclua.cbc"
local task = require "cbclua.task"
local sweep = require "sweep"
local algorithms = require "algorithms"
local motions = require "motions"

-----------

	
function main()
	motions.palms_sweep()
	motions.palms_retract()
	algorithms.follow_wall_sensor()
	algorithms.final_palm_lineup()
	motions.palms_sweep()
	motions.palms_retract()
end
