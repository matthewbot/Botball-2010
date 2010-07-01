local task = require "cbclua.task"
local create = require "mb.create"
local claw = require "claw"
local algorithm = require "algorithm"
local sponge = require "sponge"
import "config"

function main()
	claw.init()
	create.connect()
	sponge.reset()
	
	grab_dirty_ducks(20)
	grab_dirty_ducks(20)
	grab_dirty_ducks(23)
	drive:fd{inches=9} -- wall lineup
	drive:fd{vel=8, time=1}
	
	algorithm.drop_sponge(-36, "medium")
	algorithm.drop_sponge(12, "small")
	
	drive:fd{inches=15} -- wall lineup
	drive:fd{vel=8, time=1}
	drive:bk{inches=4}
	drive:rturn{degrees=90}
	drive:bk{vel=8, wait=create.bump}
	
	grab_dirty_ducks(16)
	
	algorithm.drop_sponge(-3, "large")
	
	drive:fd{inches=20} -- wall lineup
	drive:fd{vel=8, time=1}
	drive:bk{inches=4}
	drive:rturn{degrees=85}
	
	drive:fd{inches=33} -- line up against duck scoring area
	drive:fd{vel=8, time=1}
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
	--[[
	claw.lift{wait=true}
	drive:rturn{degrees=60}
	claw.release_ground()
	task.sleep(.4)
	drive:lturn{degrees=60}
	claw.up()
	claw.close()]]
	
	drive:bk{inches=15}
	drive:rturn{degrees=80}
	drive:fd{inches=37}
	drive:fd{vel=8, time=1}
	
	clean_ducks()
end
	
function grab_dirty_ducks(fddist)
	task.async(function ()
		claw.down()
		task.sleep(.5)
		claw.open()
	end)
	
	drive:fd{inches=fddist}
	claw.down_grab{wait=true}
	claw.close()
	task.sleep(.8)
	claw.up_fling()
	task.sleep(.5)
	claw.release_basket()
	task.sleep(.2)
end

function clean_ducks()
	drive:bk{inches=11} -- travel to duck zone
	drive:lturn{degrees=90}
	drive:fd{vel=8, time=1}
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
	drive:fd{inches=9}
	drive:fd{vel=8, time=1}
	
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
	drive:fd{inches=10}
	drive:fd{vel=8, time=1}
end

