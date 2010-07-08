local task = require "cbclua.task"
local create = require "mb.create"
local claw = require "claw"
local algorithm = require "algorithm"
local sponge = require "sponge"
local camera = require "camera"
local os = require "os"
import "config"

function init()
	create.connect_verbose()
	claw.init()
	sponge.reset()
end

function grab_dirty_ducks(fddist, fddist_noducks, delay)
	local oiltype, direction = camera.get_oilslick()
	if oiltype == "none" then
		print("Skipping duck grab")
		drive:fd{inches=fddist_noducks}
		return oiltype
	end

	print("Grabbing ducks on " .. oiltype .. " pile direction " .. direction)
		
	task.async(function ()
		claw.down_push()
		task.sleep(.5)
		claw.open()
	end)
	
	if delay then
		task.sleep(delay)
	end
	
	if direction == "center" then
		drive:fd{inches=fddist}
	elseif direction == "left" then
		drive.style:set_vel_dist(drive.drivetrain, 18, fddist, 19, fddist, { })
	else
		drive.style:set_vel_dist(drive.drivetrain, 19, fddist, 18, fddist, { })
	end
	claw.down_grab{wait=true}
	claw.close()
	task.sleep(.8)
	claw.up_fling()
	task.sleep(.5)
	claw.release_basket()
	task.sleep(.2)
	
	return oiltype
end

function wall_lineup(fddist, either)
	local drivingasync = task.async(function ()
		if fddist then
			bdrive:fd{inches=fddist}
		end
		bdrive:fd{vel=6}
	end)
	
	local ok
	if either then
		ok = task.wait(algorithm.read_either_lineup, 2)
	else
		ok = task.wait(algorithm.read_lineups, 2)
	end
	task.sleep(.2)
	task.stop(drivingasync)
	drive:stop{}
	
	return ok
end

function clean_ducks()
	drive:bk{inches=11} -- travel to duck zone
	drive:lturn{degrees=90}
	wall_lineup(0)
	drive:bk{inches=2.5}
	
	task.async(function () -- grab first set of ducks
		task.sleep(.3)
		grip_servo(1400)
	end)
	claw.down_grab{wait=true}
	claw.close()
	task.sleep(.5) -- normal sleep
	claw.lift{wait=true}
	
	drive:bk{inches=14} -- move into position
	drive:bk{vel=8, wait=create.bump}
	drive:fd{inches=.5}
	drive:lturn{degrees=95}
	drive:bk{inches=6}
	
	claw.down_release{wait=true} -- drop first set
	claw.release_ground{speed=700, wait=true}
	task.sleep(.5)
	
	task.async(function () -- release and travel back to duck zone
		task.sleep(.3)
		claw.up()
		task.sleep(.4)
		claw.close()
	end)
	drive:bk{vel=8, wait=create.bump}
	drive:rturn{degrees=50}
	drive:fd{inches=12}
	drive:rturn{degrees=45}
	wall_lineup(3)
	
	task.async(function () -- grab second set
		task.sleep(.3)
		claw.open()
	end)
	claw.down_grab{wait=true}
	claw.close()
	task.sleep(.5)
	claw.lift{wait=true}
	
	drive:bk{inches=10} -- travel into position
	drive:lturn{degrees=90}
	drive:bk{vel=8, wait=create.bump}
	drive:fd{inches=3.5}
	
	claw.down_release{wait=true} -- release second set
	claw.release_ground{speed=700, wait=true}

	drive:bk{vel=8, wait=create.bump} -- travel into back corner
	claw.up()
	task.sleep(.4)
	claw.close()
	drive:lturn{degrees=90}
	drive:fd{inches=11}
end

