import "config"

local cbc = require "cbclua.cbc"
local task = require "cbclua.task"
local vision = require "mb.vision"
local compactor = require "compactor"

local camera

function open_camera()
	if not camera then
		camera = vision.Camera()
	end
end

function dump_grid(cm, image)
	cm = cm or cm_red
	
	open_camera()
	
	for i=1,3 do camera:readImage() end
	
	if not image then
		image = camera:readImage()
	end
	
	gip:processImage(image)
	
	print("begin dump:")
	
	for x=0,7 do
		for y=0,3 do
			local count = gip:getCount(x, y, cm)
			if count > 10 then
				print(x .. "," .. y .. " " .. count)
			end
		end
	end
end


function check_botguy()
	cm = cm_red
	open_camera()
	
	for i=1,4 do camera:readImage() end
	
	local image = camera:readImage()
	gip:processImage(image)
	
	for x=0,7 do
		for y=0,3 do
			local count = gip:getCount(x, y, cm)
			if count > 20 then
				return x, y
			end
		end
	end
end

function check_tribbles()
	return 0
end