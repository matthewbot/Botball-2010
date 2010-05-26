import "config"

local cbc = require "cbclua.cbc"
local task = require "cbclua.task"
local arm = require "arm"
local algorithms = require "algorithms"
local sweep = require "sweep"

-----------

	
function main()
	drive:fd{inches=12}
	drive:rturn{degrees=90}
	drive:fd{inches=20}
	drive:rturn{degrees=90}
	drive:fd{inches=5}
	drive:lturn{degrees=90}
	drive:fd{inches=5}
	drive:lturn{degrees=45}
	drive:fd{inches=5}
	
--[[	sweep.palms()
	algorithms.follow_wall_sensor()
	algorithms.final_palm_lineup()
	sweep.botguy()
	drive:bk{speed=200, inches=2}
	sweep.palms() ]]
end
