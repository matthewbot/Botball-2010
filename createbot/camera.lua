local vision = require "mb.vision"

local camera = vision.Camera()
local black_cm = vision.ColorModel{
	lefthue = 0,
	righthue = 360,
	minsat = 0,
	maxsat = 255,
	minval = 0,
	maxval = 50
}

local bip = vision.BlobImageProcessor(1, 5, 5)
bip:addColorModel(black_cm)

function get_oilslick()
	local blob = get_oilslick_blob()
	local factor = blob.w*blob.h / (blob.y + blob.h/2)
	
	print(factor, blob.w*blob.h, blob.y+blob.h/2)
	if factor < 20 then
		return "small"
	elseif factor < 40 then
		return "medium"
	else
		return "large"
	end
end

function get_oilslick_blob()
	for i=1,3 do
		camera:readImage()
	end
	
	local image = camera:readImage()
	bip:processImage(image)
	
	print("Count", bip:getBlobCount())
	for i=0,bip:getBlobCount()-1 do
		local blob = bip:getBlob(i)
		
		if blob.y < 100 then
			return blob
		end
	end
end

