local task = require "cbclua.task"
local cbc = require "cbclua.cbc"
local algorithm = require "cbclua.algorithm"
local create = require "mb.create"
local lance = require "lance"
local scripts = require "scripts"
import "main_shared"
import "config"

function main()
	init()
	
	lance_sweep()
	after_sweep_lineup()
	dirty_ducks_de()
	
	clean_ducks()
end

function lance_sweep()
	task.async(function ()
		task.sleep(2.2)
		lance.extend()
	end)
	scripts.sweep_position:play()
	
	bdrive:rturn{degrees=10, vel=8}
	task.sleep(.6)
	bdrive:rturn{degrees=45, vel=9}
	bdrive:rturn{degrees=45, vel=5}
	lance.retract()
end

--[[
function after_sweep_lineup()
	drive:lpiv{vel=-8, wait=create.bump}
	drivetrain:drive(-8, 5)
	task.sleep(.4)
	task.wait_while(create.bump)
	drivetrain:drive(0, 0)
	drive:bk{vel=10, wait=create.bump}
	drive:lturn{degrees=80}
	drive:fd{vel=8, time=1}
	drive:lpiv{degrees=-27}
	
	drive:bk{inches=38}
	drive:rturn{degrees=130}
	wall_lineup(25)
	drive:bk{inches=5}
	drive:rturn{degrees=90}
	wall_lineup(3)
	drive:bk{inches=4}
	drive:rturn{degrees=90}
end
]]--

function after_sweep_lineup()
	bdrive:lturn{degrees=5}
	wall_lineup(6)
	drive:rpiv{degrees=-45}
	
	drive:bk{inches=30}
	drive:rturn{degrees=130}
	wall_lineup(28)
	drive:bk{inches=5}
	drive:rturn{degrees=90}
	wall_lineup(3)
	drive:bk{inches=4}
	drive:rturn{degrees=90}
end

function dirty_ducks_de()
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
	oilslicks[3] = grab_dirty_ducks(20, 20)
	wall_lineup(4)
	
	drive:bk{inches=14}
	drive:lturn{degrees=180}
	
	drop_sponge(-2, 3)
	if not drop_sponge(10, 2) then
		drive:fd{inches=10}
	end
	
	if not drop_sponge(10, 1) then
		drive:fd{inches=10}
	end
	
	-- possible additional fd bk?
	drive:lturn{degrees=90}
	wall_lineup(15)
	
	claw.down_push{wait=true}
	claw.release_ground() -- release a duck possibly still in our claw
	task.sleep(.3)
	claw.up()
	task.sleep(.5)
	claw.close()

	drive:bk{inches=1}
	drive:lturn{degrees=90}
	drive:bk{inches=3} -- probably needed to align basket w/ oily duck center
	claw.down_push{wait=true}
	claw.eject()
	task.sleep(.4)
	claw.up{}

	drive:lturn{degrees=178}
	wall_lineup(15) -- possibly shorter?
end

