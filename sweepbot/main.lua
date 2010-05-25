import "config"

local cbc = require "cbclua.cbc"
local task = require "cbclua.task"
local arm = require "arm"
local algorithms = require "algorithms"
local sweep = require "sweep"

-----------

	
function main()
	sweep.palms()
	algorithms.follow_wall_sensor()
	algorithms.final_palm_lineup()
	sweep.botguy()
	sweep.palms()
end
