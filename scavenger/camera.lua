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

function return_highest(list, return_pos)
	local highest = list[1]
	
	return_pos = return_pos or false
	local pos = 1
	
	print("list[1]: " .. tostring(list[1]))
	
	if highest then
		print("#list: " .. #list)
		print("first highest: " .. highest)

		for k = 2, #list do
			if list[k] > highest then
				print("k: " .. k)
				highest = list[k]
				print("new highest: " .. highest)
				pos = k
			end
		end
	end
	
	if return_pos == true then
		return highest, pos
	end
	
	return highest
end

function check_closeness(y_list, conc_list)
	print("checking closeness")
	
	local highest, pos = return_highest(conc_list, true)
	
	print("highest: " .. tostring(highest))
	print("pos: " .. pos .. " y_list[pos]: " .. tostring(y_list[pos]))
	
	if highest then
		if y_list[pos] > 1 and y_list[pos] <= 3 then
			return true
		end
	end
	
	return false
end

function check_nil(value)
	if not value then
		return value
	end
	
	return -1
end

function find_item(item, return_image, old_image)	
	local botguy, tribbles, cm, x_cutoff, count_cutoff
	if item == "botguy" then
		botguy = true
		cm = cm_red
		x_cutoff = 7
		count_cutoff = 30
	elseif item == "tribbles" then
		tribbles = true
		cm = cm_green
		x_cutoff = 5
		count_cutoff = 20
	else
		return nil
	end
	
	local max_x, min_x
	local k = 0
	local once = false
	local x_list, y_list, count_list = {}, {}, {}
	
	local image
	if not old_image then
		image = take_image(6)
	else
		image = old_image
	end
	--dump_grid(cm, image)
	
	gip:processImage(image)
	
	for x=0,x_cutoff do
		for y=0,3 do
			local count = gip:getCount(x, y, cm)
			if x == 4 and y == 3 then
				print("skip")
			else
				if count > count_cutoff then
					k = k + 1
					print("k: " .. k)
					if botguy then
						y_list[k] = y
						count_list[k] = count
						
						if not once then
							min_x = x
							once = true
						end
					elseif tribbles then
						x_list[k] = x
					end
				end
			end
		end
	end
	
	return_image = return_image or false
	if botguy then
		print("min_x: " .. tostring(min_x))
		local close = check_closeness(y_list, count_list)
		
		min_x = check_nil(min_x)
		
		if return_image then
			return close, min_x, image
		else
			return close, min_x
		end
	elseif tribbles then
		print("max_x: " .. tostring(max_x))
	
		max_x = return_highest(x_list)
		max_x = check_nil(max_x)
			
		if return_image then
			return max_x, image
		else
			return max_x
		end
	end
	
	return nil
end

function find_botguy() find_item("botguy") end
function find_tribbles() find_item("tribbles") end
function find_both()
	local close, min_x, image = find_item("botguy", true)
	local max_x = find_item("tribbles", false, image)
	return close, min_x, max_x
end