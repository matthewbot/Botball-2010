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
	
	oilslicks[1] = camera.get_oilslick() -- me ugly
	print(oilslicks[1])
	if oilslicks[1] ~= "none" then
		grab_dirty_ducks(20)
	else
		drive:fd{inches=20}
	end
	oilslicks[2] = camera.get_oilslick()
	print(oilslicks[2])
	if oilslicks[2] ~= "none" then
		grab_dirty_ducks(20)
	else
		drive:fd{inches=22}
	end
	oilslicks[3] = camera.get_oilslick()
	print(oilslicks[3])
	if oilslicks[3] ~= "none" then
		grab_dirty_ducks(23)
	else
		drive:fd{inches=25}
	end
	
	wall_lineup(9)
	
	if oilslicks[1] ~= "none" then
		algorithm.drop_sponge(-36, oilslicks[1])
	else
		drive:bk{inches=36}
	end
	
	if oilslicks[2] ~= "none" then
		algorithm.drop_sponge(12, oilslicks[2])
	else
		drive:fd{inches=24}
	end
	
	wall_lineup(15)
	drive:bk{inches=4}
	drive:rturn{degrees=90}
	drive:bk{vel=8, wait=create.bump}
	
	oilslicks[4] = camera.get_oilslick()
	print(oilslicks[4])
	grab_dirty_ducks(22)
	
	if oilslicks[3] ~= "none" then
		algorithm.drop_sponge(-5, oilslicks[3])
		wall_lineup(20) -- wall lineup
	else
		wall_lineup(16) -- wall lineup, slightly less
	end
	drive:bk{inches=4}
	drive:rturn{degrees=90}
	
	oilslicks[5] = camera.get_oilslick()
	print(oilslicks[5])
	if oilslicks[5] ~= "none" then
		grab_dirty_ducks(24, .5)
		drive:bk{inches=8}
	else
		drive:fd{inches=15}
	end
	
	if oilslicks[4] ~= "none" then
		algorithm.drop_sponge(-2, oilslicks[4])
		wall_lineup(33) -- line up against duck area
	else
		wall_lineup(36) -- line up against duck area
	end
	claw.down{wait=true}
	claw.release_ground() -- release a duck possibly still in our claw
	task.sleep(.3)
	claw.up()
	task.sleep(.5)
	claw.close()
	drive:bk{inches=1}
	drive:lturn{degrees=85}
	claw.down{wait=true}
	claw.eject()
	claw.up{wait=true}
	
	if oilslicks[5] ~= "none" then
		drive:fd{inches=15}
		algorithm.drop_sponge(-2, oilslicks[5])
	end
	--[[
	claw.lift{wait=true}
	drive:rturn{degrees=60}
	claw.release_ground()
	task.sleep(.4)
	drive:lturn{degrees=60}
	claw.up()
	claw.close()]]
end
	
function grab_dirty_ducks(fddist, delay)
	task.async(function ()
		claw.down()
		task.sleep(.5)
		claw.open()
	end)
	
	if delay then
		task.sleep(delay)
	end
	drive:fd{inches=fddist}
	claw.down_grab{wait=true}
	claw.close()
	task.sleep(.8)
	claw.up_fling()
	task.sleep(.5)
	claw.release_basket()
	task.sleep(.2)
end

function wall_lineup(fddist)
	if fddist then
		drive:fd{inches=fddist}
	end
	drive:fd{vel=8, time=1}
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
	task.sleep(.5)
	claw.lift{wait=true}
	
	drive:bk{inches=14} -- move into position
	drive:bk{vel=8, wait=create.bump}
	drive:lturn{degrees=95}
	drive:bk{inches=7.25}
	
	claw.down{wait=true} -- drop first set
	claw.release_ground{speed=700, wait=true}
	task.sleep(.5)
	
	task.async(function () -- release and travel back to duck zone
		task.sleep(.3)
		claw.up()
		task.sleep(.4)
		claw.close()
	end)
	drive:bk{vel=8, wait=create.bump}
	drive:rturn{degrees=45}
	drive:fd{inches=14}
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
	drive:bk{inches=5}
	
	claw.down{wait=true} -- release second set
	claw.release_ground{speed=700, wait=true}

	drive:bk{vel=8, wait=create.bump} -- travel into back corner
	claw.up()
	task.sleep(.4)
	claw.close()
	drive:lturn{degrees=90}
	wall_lineup(10)
end

