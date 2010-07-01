import "config"

local cbc = require "cbclua.cbc"
local task = require "cbclua.task"
local compactor = require "compactor"
local motion = require "motion"
local grabs = require "grabs"
local moves = require "moves"

function main()
	compactor.init()
	moves.goto_pvc_island()
	
	moves.grab_our_leg()

	--scenario B:not going into the middle
	
	--scenario A:going into the middle
	moves.go_into_middle()
	
	moves.go_home()
	
	drive:rturn{degrees = 180}
	motion.drive_sensor("right", "fd", "no_pvc", 900, 350)
	drive:fd{inches = 3}
	drive:rturn{degrees = 46}
	drive:fd{inches = 22}

	moves.grab_our_leg()

	moves.go_into_middle()
	
	moves.go_home()
	
	--[[compactor.close()
	
	local l, r = 800, 800
	
	while true do
		task.wait(cbc.a_button)
	
		motion.arc_mav(l, r)
		
		print("r = " .. r)
		
		task.wait(cbc.b_button)
	
		motion.arc_off()
		
		r = r - 10

		if r <= 0 then
			break
		end
	end
	]]--
end
