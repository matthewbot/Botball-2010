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
	
	print("open camera")
	
	for i=1,3 do camera:readImage() end
	
	print("took fake images:")
	
	if not image then
		image = camera:readImage()
	end
	
	print("took image:")
	
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

function return_highest(list)
	local highest = list[1]
	local num = 1
	
	if not highest then
		highest = 0
	else
		print("#list: " .. #list)
		print("first highest: " .. highest)
	
		for k = 2, #list do
			if list[k] > highest then
				print("k: " .. k)
				highest = list[k]
				print("new highest: " .. highest)
				num = k
			end
		end
	end
	
	return highest, num
end

function check_closeness(y_list, conc_list)
	print("checking closeness")
	--[[for i = 1, end_pt do
		if list[i] == 3 then
			return true
		end
	end]]--
	
	local high_count, num = return_highest(conc_list)
	
	print("num: " .. num .. " y_list[num]: " .. y_list[num])
	
	if high_count ~= 0 then
		if y_list[num] > 1 and y_list[num] <= 3 then
			return true
		end
	else
		return false
	end
end

function find_botguy()
	local cm = cm_red
	open_camera()
	
	print("opening camera!!!!!")
	
	local once, min_x
	local k = 0
	local y_list, count_list = {}, {}	
	
	for i=1,3 do camera:readImage() end
	
	local image = camera:readImage()
	dump_grid(cm, image)
	
	gip:processImage(image)
	
	for x=0,7 do
		for y=0,3 do
			local count = gip:getCount(x, y, cm)
			if count > 20 then
				k = k + 1
				print("k: " .. k)
				y_list[k] = y
				count_list[k] = count
				
				if not once then
					min_x = x
					once = true
				end
			end
		end
	end

	local close = check_closeness(y_list, count_list)
	
	return close, min_x	
end

function find_tribbles()
	local cm = cm_green
	open_camera()
	
	local once, min_x
	local k = 0
	local y_list = {}	
	
	for i=1,4 do camera:readImage() end
	
	local image = camera:readImage()
	gip:processImage(image)
	
	for x=0,7 do
		for y=0,3 do
			local count = gip:getCount(x, y, cm)
			if count > 20 then
				k = k + 1
				y_list[k] = y
				
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
		return check_closeness(y_list, k, min_x)
	end
end