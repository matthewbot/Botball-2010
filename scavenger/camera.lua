import "config"

local cbc = require "cbclua.cbc"
local task = require "cbclua.task"
local vision = require "mb.vision"
local compactor = require "compactor"


function open_camera() return vision.Camera() end
function close_camera(camera) camera:close() end

function take_image(fake_pics)
	local camera = open_camera()
	
	print("open camera")
	
	for i=1,fake_pics do 
		camera:readImage() 
	end

	print("took fake images:")
	
	local image = camera:readImage()

	print("took image:")
	
	close_camera(camera)
	
	return image
end

function dump_grid(cm, image)
	local cm = cm or cm_red
	
	if not image then
		image = take_image(6)
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

function return_highest(list, num_return)
	local highest = list[1]
	
	num_return = num_return or false
	local num = 1
	
	
	print("list[1]: " .. tostring(list[1]))
	
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
	
	if num_return == true then
		return highest, num
	end
	
	return highest
end

function check_closeness(y_list, conc_list)
	print("checking closeness")
	
	local highest, num = return_highest(conc_list, true)
	
	print("highest: " .. highest)
	print("num: " .. num .. " y_list[num]: " .. tostring(y_list[num]))
	
	if highest ~= 0 then
		if y_list[num] > 1 and y_list[num] <= 3 then
			return true
		end
	end
	
	return false
end

function find_botguy()
	local cm = cm_red
		
	local once, min_x
	local k = 0
	local y_list, count_list = {}, {}	
	
	local image = take_image(6)
	dump_grid(cm, image)
	
	gip:processImage(image)
	
	for x=0,7 do
		for y=0,3 do
			local count = gip:getCount(x, y, cm)
			if x == 4 and y == 3 then
				print("skip")
			else
				if count > 30 then
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
	end

	print("min_x: " .. tostring(min_x))
	local close = check_closeness(y_list, count_list)
	
	return close, min_x	
end

function find_tribbles()
	local cm = cm_green
		
	local k, max_x = 0
	local x_list = {}	
	
	local image = take_image(6)
	--dump_grid(cm, image)
	
	gip:processImage(image)
	
	for x=0,5 do
		for y=0,3 do
			local count = gip:getCount(x, y, cm)
			if x == 4 and y == 3 then
				print("skip")
			else
				if count > 20 then
					k = k + 1
					print("k: " .. k)
					x_list[k] = x
				end
			end
		end
	end

	print("max_x: " .. tostring(max_x))
	
	max_x = return_highest(x_list)
	
	if max_x ~= 0 then
		return max_x
	end
	
	return nil
end