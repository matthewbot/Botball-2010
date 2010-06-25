import "config"

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
	
end
