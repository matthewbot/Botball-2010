import "config"
import "drive"
import "sweep"



local vision = require "cbclua.vision"
local math = require "math"

local turntime_constant = 1

function get_poms()
	vision.update()
	local a = green_channel[0]
	local b = green_channel[1]
	
	if a.size < 50 then
		return false
	elseif b.size < 50 then
		return a.x_float
	else
		return (a.x_float + b.x_float)/2
	end
end

function face_poms()
	local poms = get_poms()
	if not poms then return false end
	
	local turntime = math.abs(poms) * turntime_constant
	if poms > 0 then
		drive_rturn(turntime, 200)
	else
		drive_lturn(turntime, 200)
	end	
end
