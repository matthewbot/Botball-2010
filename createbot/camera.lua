local vision = require "mb.vision"
local math = require "math"

black_cm = vision.ColorModel{
	lefthue = 0,
	righthue = 360,
	minsat = 0,
	maxsat = 255,
	minval = 0,
	maxval = 60, -- was 70
}

bip = vision.BlobImageProcessor(3, 4, 4)
bip:addColorModel(black_cm)

gip = vision.GridImageProcessor(5, 5)
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
	
	local y = blob.y + blob.h/2
	local sizefactor = blob.w*blob.h / (y + .0000003 * y^4)
	local xfactor = blob.x+blob.w/2

	print("Oilslick factors", sizefactor, xfactor)
	print("Oilslick blob", blob)
	
	local dir 
	if xfactor < 70 then
		dir = "left"
	elseif xfactor > 90 then
		dir = "right"
	else
		dir = "center"
	end
	
	local size
	if sizefactor < 25 then
		size = "small"
	elseif sizefactor < 50 then
		size = "medium"
	else
		size = "large"
	end
	return size, dir
end

function get_oilslick_blob(count)
	local camera = vision.Camera()
	for i=1,count do
		camera:readImage()
	end
	
	local image = camera:readImage()
	camera:close()
	bip:processImage(image)
	
	for i=0,bip:getBlobCount()-1 do
		local blob = bip:getBlob(i)
		
		local x, y = blob.x+blob.w/2, blob.y+blob.h/2
		print("x", x, "y", y, "area", blob.w*blob.h)
		if y > 5 and y < 105 and x > 40 and x < 120 then
			return blob
		end
	end
end

