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
	local cm = cm or cm_red
	
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

function check_closeness(list, end_pt, min_x)
	for i = 1, end_pt do
		if list[i] == 3 then
			return true
		end
	end
	
	return min_x
end

function check_botguy()
	local cm = cm_red
	open_camera()
	
	local once, min_x
	local num = 0
	local y_list = {}	
	
	for i=1,4 do camera:readImage() end
	
	local image = camera:readImage()
	gip:processImage(image)
	
	for x=0,7 do
		for y=0,3 do
			local count = gip:getCount(x, y, cm)
			if count > 20 then
				num = num + 1
				y_list[num] = y
				
				if not once then
					min_x = x
					once = true
				end
			end
		end
	end
	
	if not min_x then
		return false
	else
		return check_closeness(y_list, num, min_x)
end

function check_tribbles()
	local cm = cm_green
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