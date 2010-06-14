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
	drive:bk{inches=32}
	drive:bk{inches=3}
	drive:fd{inches=4.5}
	drive:lturn{degrees=90}
	drive:fd{inches=13}
	drive:off()
	algorithms.wall_lineup_bumpers()
	drive:bk{inches=1.25}
	arm.extend(550, 400)
	drive:lturn{degrees=90}
	drive:bk{inches=6}
	drive:fd{inches=1}
	drive:scooch{xdist=2, speed=300}
	drive:fd{inches=10}
	drive:lturn{degrees=40}
	arm.extend(400, 400)
	drive:bk{inches=3}
	sweep.palms()
--[[	algorithms.follow_wall_sensor()
	algorithms.final_palm_lineup()
	sweep.botguy()
	drive:bk{speed=200, inches=2}
	sweep.palms() ]]
end
