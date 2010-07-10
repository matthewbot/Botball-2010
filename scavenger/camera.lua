import "config"

local cbc = require "cbclua.cbc"
local task = require "cbclua.task"
local vision = require "mb.vision"
local compactor = require "compactor"

function open_camera() return vision.Camera() end
function close_camera(cam) cam:close() end

function take_image(fake_pics)
	local cam = open_camera()
	
	print("open camera")
	
	for i=1,fake_pics do 
		cam:readImage() 
	end

	print("took fake images:")
	
	local image = cam:readImage()

	print("took image:")
	
	close_camera(cam)
	
	return image
end

function dump_grid(cm, image)
	print("take dump images")
	
	if image == nil then
		image = take_image(6)
		gip:processImage(image)
	end
	
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
			return "close"
		end
	end
	
	return "not_close"
end

function check_nil(value)
	if value ~= nil then
		return value
	end
	
	return -1
end

function find_item(item, capture_image)	
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
	
	if capture_image == nil then
		capture_image = true
	end
	
	local image
	if capture_image == true then
		image = take_image(6)
		gip:processImage(image)
	end
	dump_grid(cm, image)
	

	
	for x=0,x_cutoff do
		for y=0,3 do
			local count = gip:getCount(x, y, cm)
			if (x == 4 and y == 3) or (x == 0 and y == 3) then
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
	
	print("botguy: ", botguy)
	if botguy == true then
	local close
	local high_conc = return_highest(count_list)
	print("high_conc: " ..  tostring(high_conc))
		if high_conc ~= nil and high_conc > 100 then
			min_x = check_nil(min_x)
			close = check_closeness(y_list, count_list)
		else
			min_x = -1
			close = "not_close"
		end
		print("min_x: " .. tostring(min_x))
		
		print("close ", close)
		print("          ")
		
		return close, min_x
	elseif tribbles == true then
		print("max_x: " .. tostring(max_x))
		print("          ")
	
		max_x = return_highest(x_list)
		max_x = check_nil(max_x)
			
		return max_x
	end
	
	return nil
end

function find_botguy() return find_item("botguy") end
function find_tribbles() return find_item("tribbles") end
function find_both()
	print("printing botguy check, normal")
	print("          ")
	local close, min_x = find_item("botguy", true)
	print("          ")
	print("printing tribbles w/o second pic")
	print("          ")
	local max_x = find_item("tribbles", false)
	print("          ")
	return close, min_x, max_x
end