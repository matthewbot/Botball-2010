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

function b()
	cbc.beep()
end	

function main()
--[[	task.async(init)
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
	drive:bk{inches=7}
	drive:fd{inches=1}
	bdrive:scooch{xdist=4, speed=300}
	drive:fd{inches=8}
	drive:lturn{degrees=45}
	arm.extend(400, 600)
	drive:bk{inches=2}
	--------------
	-- Sweeping --
	--------------
	sweep.palms()
	drive:fd{inches=1.5}
	sweep.palms()]]
	algorithms.follow_wall_sensor()
	algorithms.final_palm_lineup()
	sweep.botguy()
	task.sleep(.5) -- is needed?
	dumper.shake()
	drive:bk{speed=200, inches=1.5}
	sweep.palms()
	drive:fd{inches=1.5}
	sweep.palms()
	---------------
	-- Returning --
	---------------
	task.async(function ()
		arm.extend(800, 500)
		arm.pitch(400, 500)
	end)
	drive:bk{inches=4}
	drive:lturn{degrees=45}
	drive:bk{inches=14}
	drive:bk{inches=2, speed=400}
	drive:fd{inches=5}
	drive:rturn{degrees=90}
	drive:bk{inches=14}
	drive:rturn{degrees=20}
	drive:bk{inches=2}
	drive:lturn{degrees=20}
	drive:bk{inches=5}
	drive:bk{inches=2, speed=400}
	drive:fd{inches=4}
	drive:rturn{degrees=90}
	drive:bk{inches=14}
	drive:rturn{degrees=90}
	drive:bk{inches=8, speed=500}
	drive:fd{inches=34}
	drive:lturn{degrees=98}
	drive:fd{inches=37}
	algorithms.wall_lineup_bumpers()
	drive:bk{inches=7}
	dumper.dump()
	drive:fd{inches=5}
	dumper.reset()
	drive:rturn{degrees=90}
	drive:bk{inches=2}
end
