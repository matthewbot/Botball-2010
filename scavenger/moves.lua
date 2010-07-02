import "config"

local cbc = require "cbclua.cbc"
local task = require "cbclua.task"
local math = require "math"
local compactor = require "compactor"
local grabs = require "grabs"
local motion = require "motion"
local camera = require "camera"

--Scenario A
function goto_pvc_island(block)
	block = block or false
	
	drive:fd{inches = 38}
	drive:rturn{degrees = 54}
	motion.drive_sensor("right", "fd", "pvc", 800, 600)
	motion.drive_sensor("right", "fd", "no_pvc", 800, 350)
	drive:fd{inches = 15}
	
	--[[drive:fd{inches = 38}
	drive:rturn{degrees = 40}
	drive:fd{inches = 24}]]--hit pvc of the island
end

function grab_our_leg()
	grabs.tribbles_pvc_bk(0.32)
	drive:bk{inches = 2}
	drive:rturn{degrees = 96}
	
	local result = camera.check_botguy()
	
	if type(result) == "number" then
		print("x_pos: " .. result)
	else
		print("close?: " .. result)
	end
	
	compactor.open()
	motion.drive_sensor("right", "fd", "pvc", 650, 600)
	drive:fd{inches = 7}
	
	if result == true or (result >= 2 and result <= 5) then
		grabs.botguy_pvc()
	end
		
	
	--[[drive:scooch{xdist = -0.75}
	motion.drive_sensor("right", "fd", "pvc", 650, 600)
	drive:fd{inches = 7}
	grabs.tribbles_pvc()]]--
end

function go_into_middle()  --middle = no touch zone
	drive:lpiv{degrees = -30}
	drive:rpiv{degrees = 37}
	--local tribble_async = task.async(grabs.tribbles) --to stay or not to stay?
	drive:scooch{xdist = 0.75, dir = "bk"}
	--task.join(tribble_async)
	drive:scooch{xdist = 0.5}
	
	compactor.open()
	motion.drive_sensor("left", "fd", "pvc", 650, 500)
	drive:fd{inches = 14}
	grabs.tribbles_pvc_full()
end

function go_home()
	motion.drive_sensor("left", "bk", "pvc", 900, 500)
	drive:bk{inches = 13}
	drive:rpiv{degrees = 37}
	drive:lpiv{degrees = -30}
	
	motion.drive_sensor("left", "fd", "no_pvc", 900, 500)
	drive:fd{inches = 1}
	drive:lturn{degrees = 85}
	motion.drive_sensor("left", "fd", "pvc", 900, 400)
	motion.drive_sensor("left", "fd", "no_pvc", 900, 350)
	drive:fd{inches = 1}
	drive:lturn{degrees = 91}
	drive:fd{inches = 39}
	grabs.release()
end

--Scenario C
function block(dist)
	goto_pvc_island(true)--22 inches to get close to the pvc of the island

	drive:rturn{degrees = 90}
	compactor.close()
	compactor.extend_full()
	
	dist = dist or 0
	if dist < 0 then
		drive:bk{inches = math.abs(dist)}
	else
		drive:fd{inches = dist}
	end
	
	door_servo:disable()
end
