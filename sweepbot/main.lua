import "config"

local cbc = require "cbclua.cbc"
local botball = require "cbclua.botball"
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
	botball.start(starting_light)
	task.async(init)						-- sets up robot as we leave the base
	drive:bk{inches=26}
	drive:rturn{degrees=94}
	drive:bk{inches=28}	-- aligning the first time on PVC of the island area
	drive:bk{inches = 8, speed = 400}
	drive:fd{inches=4.5}
	drive:lturn{degrees=95}
	drive:fd{}
	algorithms.drive_wall()
	print("already hit wall with sensor")
	
	drive:bk{inches=1.25}
	arm.extend(550, 600)
	drive:lturn{degrees=93}
	drive:bk{inches=7, speed = 400}
	drive:fd{inches=1}
	drive:scooch{xdist=4, speed=500}		-- scooch getting ready to go sweep
	drive:fd{inches=8}
	drive:lturn{degrees=47}
	arm.extend(400, 600)
	drive:fd{inches=1.5}
	algorithms.lineup_first_palm_sweep()	-- lining up to sweep the palms
	drive:bk{inches=.5}
	
	print("go for first sweep")
	--------------
	-- Sweeping --
	--------------
	drive:lturn{degrees=2}
	sweep.palms()							-- sweeping palms
	print("sweepped first set of palms")
	drive:rturn{degrees=3}
	algorithms.follow_wall_sensor()			-- driving to PVC on other end of island to line up for next sweeps
	algorithms.final_palm_lineup()
	sweep.botguy()							-- sweeping botguy
	print("sweepped botguy")
	task.sleep(.5) -- is needed?
	dumper.shake()
	drive:bk{speed=500, inches=1.5}
	drive:lturn{degrees=3}
	sweep.palms()							-- sweeping second palms pile
	print("sweepped second set of palms")
	drive:rturn{degrees=3}
	---------------
	-- Returning --
	---------------
	task.async(function ()
		arm.extend(800, 500)
		arm.pitch(400, 500)
	end)
	drive:bk{inches=9}
	drive:lturn{degrees=48}
	drive:bk{inches=7}
	drive:bk{inches=4, speed=400}			-- lining up on PVC after all sweeps
	drive:fd{inches=6}
	drive:rturn{degrees=94}
	botball.game_time_sleep(78)
	print("first right turn when going home")
	
	drive:bk{inches=19}
	drive:bk{inches=7, speed=400}			-- lining up on PVC by duck corner to return to base
	drive:fd{inches=4}
	drive:rturn{degrees=92}
	print("second right turn when going home")
	drive:bk{inches=14}
	drive:rturn{degrees=90}
	drive:bk{inches=8, speed=500}			-- lining up on PVC by island again
	task.async(sweep.activate)
	drive:fd{inches=34}
	drive:lturn{degrees=94}
	botball.game_time_sleep(119)
	
	drive:fd{inches = 20}
	algorithms.drive_wall()					-- driving into base until it hits PVC
	drive:bk{inches=6}
	dumper.dump()
	task.async(dumper.shake)
	bdrive:lpiv{degrees=18}
	bdrive:rpiv{degrees=18}
	bdrive:lpiv{degrees=18}
	bdrive:rpiv{degrees=18}
--[[	if dumper.reset_check() == true then	-- if we still have botguy locked in the dumper on accident, this will keep us from pushing him out of the base, while still getting all palms in the base
		drive:fd{inches=5}
		drive:lturn{degrees=90}
		drive:bk{inches=15}
		else]]
		drive:bk{inches = 5}
		drive:rturn{degrees=94}
	--[[end]]
end

function reset_run()						--this is just for fun, it realigns the robot for the next run in the base after it has finished its previous run
	print "running the reset thing"
	drive:rturn{degrees=90}
	drive:bk{inches=8, speed=400}
	drive:fd{inches=8}
	drive:lturn{degrees=90}
	drive:bk{inches=10, speed=400}
	drive:fd{inches=5}
	drive:lturn{degrees=90}
	drive:bk{inches=15}
end