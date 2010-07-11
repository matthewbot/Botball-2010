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
	botball.start(starting_light)
	compactor.init()
	
	moves.summit()
end
