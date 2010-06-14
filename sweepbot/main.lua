import "config"

local cbc = require "cbclua.cbc"
local task = require "cbclua.task"
local arm = require "arm"
local algorithms = require "algorithms"
local sweep = require "sweep"
local dumper = require "dumper"

-----------
function init()
	sweep.init()
	dumper.init()
end
	
function main()
	task.async(init)
	drive:bk{inches=27}
	drive:rturn{degrees=90}
	drive:bk{inches=36}
	drive:fd{inches=4.5}
	drive:lturn{degrees=98}
	drive:fd{}
	algorithms.drive_wall()
	drive:bk{inches=1.25}
	arm.extend(550, 400)
	drive:lturn{degrees=98}
	drive:bk{inches=6}
	drive:fd{inches=1}
	bdrive:scooch{xdist=4, speed=300}
	drive:fd{inches=9}
	drive:lturn{degrees=45}
	arm.extend(400, 600)
	drive:bk{inches=2.5}
	--------------
	-- Sweeping --
	--------------
	sweep.palms()
	algorithms.follow_wall_sensor()
	algorithms.final_palm_lineup()
	sweep.botguy()
	drive:bk{speed=200, inches=2}
	sweep.palms()
	---------------
	-- Returning --
	---------------
	drive:bk{inches=16}
	drive:rturn{degrees=40}
	drive:bk{inches=10}
	drive:bk{inches=2, speed=400}
	drive:fd{inches=4}
	drive:rturn{degrees=90}
	drive:bk{inches=13}
	drive:rturn{degrees=90}
	drive:bk{inches=3, speed=400}
	drive:fd{inches=32}
	drive:rturn{degrees=90}
	drive:bk{inches=27}
	dumper.dump()
	drive:fd{inches=4}
	dumper.reset()
end
