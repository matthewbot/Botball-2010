import "config"

local cbc = require "cbclua.cbc"
local botball = require "cbclua.botball"
local task = require "cbclua.task"
local compactor = require "compactor"
local motion = require "motion"
local grabs = require "grabs"
local moves = require "moves"
local camera = require "camera"

function init()
	local cam = camera.open_camera()
	camera.close_camera(cam)
	compactor.init()
end

function main()
	--botball.start(starting_light)
	compactor.init()
	--[[moves.goto_pvc_island()
	
	moves.grab_our_leg()

	--scenario B:not going into the middle
	
	--scenario A:going into the middle
	moves.go_into_middle()
	--moves.go_under_island()
	moves.go_home()]]--
	
	moves.summit()
	--moves.snow()
	
	--[[drive:rturn{degrees = 180}
	motion.drive_sensor("right", "fd", "no_pvc", 900, 350)
	drive:fd{inches = 3}
	drive:rturn{degrees = 46}
	drive:fd{inches = 22}

	moves.grab_our_leg()

	moves.go_into_middle()
	
	moves.go_home()]]--
end
