import "config"

local cbc = require "cbclua.cbc"
local task = require "cbclua.task"
local arm = require "arm"
local algorithms = require "algorithms"
local sweep = require "sweep"

-----------

	
function main()
	drive:rturn{degrees=90, speed=400}
	drive:fd{inches=40}						--leave base
	drive:lturn{degrees=90, speed=400}
	drive:bk{inches=32}						--ready to start approach to danger zone
	drive:bk{inches=3, speed=400}
	drive:fd{inches=3}
	drive:rturn{degrees=90, speed=400}
	drive:bk{inches=22}						--begin approach to danger zone
	drive:bk{inches=3, speed=400}
	drive:fd{inches=4}						--lineup
	drive:lturn{degrees=90}
	drive:bk{inches=22}						--enter danger zone
--	drive:lturn{degrees=45}
--	drive:fd{inches=5}
	
--[[	sweep.palms()
	algorithms.follow_wall_sensor()
	algorithms.final_palm_lineup()
	sweep.botguy()
	drive:bk{speed=200, inches=2}
	sweep.palms() ]]
end
