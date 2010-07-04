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

function dirty_ducks()
	local oilslicks = { }
	local dropped_small = false
	
	local function drop_sponge(dist, num)
		local slick = oilslicks[num]
		if slick == "none" then
			return false
		elseif slick == "small" then
			if dropped_small then
				return false
			else
				dropped_small = true
			end
		end
		algorithm.drop_sponge(dist, oilslicks[num])
		
		return true
	end
	
	oilslicks[1] = grab_dirty_ducks(20, 20)
	oilslicks[2] = grab_dirty_ducks(20, 21)
	oilslicks[3] = grab_dirty_ducks(23, 22)
	wall_lineup(9)
	
	if not drop_sponge(-36, 1) then
		drive:bk{inches=36}
	end
	
	if not drop_sponge(12, 2) then
		drive:fd{inches=24}
	end
	
	wall_lineup(15)
	drive:bk{inches=4}
	drive:rturn{degrees=90}
	bdrive:bk{vel=8, wait=create.bump}
	oilslicks[4] = grab_dirty_ducks(22, 23)
	
	if drop_sponge(-5, 3) then
		wall_lineup(20) -- wall lineup
	else
		wall_lineup(16) -- wall lineup, slightly less
	end
	drive:bk{inches=4}
	drive:rturn{degrees=90}
	
	oilslicks[5] = grab_dirty_ducks(24, 20, .5)
	
	if drop_sponge(-2, 4) then
		wall_lineup(26, true) -- line up against duck area
	else
		wall_lineup(20, true) -- line up against duck area
	end
	
	if drop_sponge(-1, 5) then
		wall_lineup(1, true)
	end
	
	claw.down_push{wait=true}
	claw.release_ground() -- release a duck possibly still in our claw
	task.sleep(.3)
	claw.up()
	task.sleep(.5)
	claw.close()
	drive:bk{inches=1}
	drive:lturn{degrees=85}
	claw.down_push{wait=true}
	claw.eject()
	task.sleep(.2)
	claw.up{wait=true}
	
	--[[
	claw.lift{wait=true}
	drive:rturn{degrees=60}
	claw.release_ground()
	task.sleep(.4)
	drive:lturn{degrees=60}
	claw.up()
	claw.close()]]
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
		bdrive:fd{vel=8}
	end)
	
	local ok
	if either then
		ok = task.wait(algorithm.read_either_lineup, 4)
	else
		ok = task.wait(algorithm.read_lineups, 4)
	end
	task.sleep(.2)
	task.stop(drivingasync)
	drive:stop{}
	
	return ok
end

function clean_ducks()
	drive:bk{inches=11} -- travel to duck zone
	drive:lturn{degrees=90}
	wall_lineup()
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
	drive:bk{inches=7}
	
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
	wall_lineup(9)
	
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
	wall_lineup(5)
end

