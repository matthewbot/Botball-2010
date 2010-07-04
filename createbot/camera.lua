local vision = require "mb.vision"

local black_cm = vision.ColorModel{
	lefthue = 0,
	righthue = 360,
	minsat = 0,
	maxsat = 255,
	minval = 0,
	maxval = 40,
}

local bip = vision.BlobImageProcessor(1, 5, 5)
bip:addColorModel(black_cm)

local gip = vision.GridImageProcessor(5, 5)
gip:addColorModel(black_cm)

function dump()
	gip:processImage(camera:readImage())
	gip:dump(black_cm)
end

function get_oilslick(count)
	local blob = get_oilslick_blob(count or 5)
		
	if blob == nil then
		return "none"
	end
	
	local factor = blob.w*blob.h / (blob.y + blob.h/2)
	local xfactor = blob.x+blob.w/2

	print(factor, blob.w*blob.h, xfactor, blob.y+blob.h/2)
	
	local dir 
	if xfactor < 70 then
		dir = "left"
	elseif xfactor > 90 then
		dir = "right"
	else
		dir = "center"
	end
	
	if factor < 10 then
		return "small", dir
	elseif factor < 30 then
		return "medium", dir
	else
		return "large", dir
	end
end

function get_oilslick_blob(count)
	local camera = vision.Camera()
	for i=1,count do
		print("Reading image " .. i)
		camera:readImage()
	end
	
	print("Last image")
	local image = camera:readImage()
	print("Closing")
	camera:close()
	print("Done, processing")
	bip:processImage(image)
	
	print("Count", bip:getBlobCount())
	for i=0,bip:getBlobCount()-1 do
		local blob = bip:getBlob(i)
		
		print("y", blob.y)
		if blob.y > 10 and blob.y < 90 and blob.x+blob.w/2 > 40 and blob.x+blob.w/2 < 120 then
			return blob
		end
	end
end

