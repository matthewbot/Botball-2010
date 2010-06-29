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
	task.async(init)						-- sets up robot as we leave the base
	drive:bk{inches=27}
	drive:rturn{degrees=90}
	drive:bk{inches=36}						-- aligning the first time on PVC of the island area
	drive:fd{inches=4.5}
	drive:lturn{degrees=98}
	drive:fd{}
	algorithms.drive_wall()
	drive:bk{inches=1.25}
	arm.extend(550, 600)
	drive:lturn{degrees=98}
	drive:bk{inches=7}
	drive:fd{inches=1}
	bdrive:scooch{xdist=4, speed=500}		-- scooch getting ready to go sweep
	drive:fd{inches=8}
	drive:lturn{degrees=45}
	arm.extend(400, 600)
	drive:fd{inches=1}
	algorithms.lineup_first_palm_sweep()	-- lining up to sweep the palms
	--drive:bk{inches=1}
	--------------
	-- Sweeping --
	--------------
	drive:lturn{degrees=3}
	sweep.palms()							-- sweeping palms
	drive:rturn{degrees=3}
	algorithms.follow_wall_sensor()			-- driving to PVC on other end of island to line up for next sweeps
	algorithms.final_palm_lineup()
	sweep.botguy()							-- sweeping botguy
	task.sleep(.5) -- is needed?
	dumper.shake()
	drive:bk{speed=500, inches=1.75}
	drive:lturn{degrees=3}
	sweep.palms()							-- sweeping second palms pile
	drive:rturn{degrees=3}
	---------------
	-- Returning --
	---------------
	task.async(function ()
		arm.extend(800, 500)
		arm.pitch(400, 500)
	end)
	drive:bk{inches=4}
	drive:lturn{degrees=52}
	drive:bk{inches=12}
	drive:bk{inches=3, speed=500}			-- lining up on PVC after all sweeps
	drive:fd{inches=5}
	drive:rturn{degrees=90}
	drive:bk{inches=22}
	drive:bk{inches=4, speed=500}			-- lining up on PVC by duck corner to return to base
	drive:fd{inches=4}
	drive:rturn{degrees=90}
	drive:bk{inches=14}
	drive:rturn{degrees=90}
	drive:bk{inches=8, speed=500}			-- lining up on PVC by island again
	task.async(sweep.activate)
	drive:fd{inches=34}
	drive:lturn{degrees=98}
	algorithms.drive_wall()					-- driving into base until it hits PVC
	drive:bk{inches=7}
	dumper.dump()
	task.async(dumper.shake)
	bdrive:lpiv{degrees=20}
	bdrive:rpiv{degrees=20}
	bdrive:lpiv{degrees=20}
	bdrive:rpiv{degrees=20}
	if dumper.reset_check() == true then	-- if we still have botguy locked in the dumper on accident, this will keep us from pushing him out of the base, while still getting all palms in the base
		drive:fd{inches=5}
		drive:lturn{degrees=90}
		drive:bk{inches=15}
		else
		drive:rturn{degrees=90}
	end
end

function reset_run()
	drive:rturn{degrees=90}
	drive:bk{inches=8, speed=400}
	drive:fd{inches=8}
	drive:lturn{degrees=90}
	drive:bk{inches=10, speed=400}
	drive:fd{inches=5}
	drive:lturn{degrees=90}
	drive:bk{inches=15}
end