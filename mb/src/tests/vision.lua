vision = require "mb.vision"

camera = vision.Camera()
cm_green = vision.ColorModel{
	lefthue = 88,
	righthue = 156,
	minsat = 100,
	minval = 100
}
cm_red = vision.ColorModel{
	lefthue = 336,
	righthue = 41,
	minsat = 100,
	minval = 100	
}
cm_bluegreen = vision.ColorModel{
	lefthue = 64,
	righthue = 184,
	minsat = 80,
	minval = 80	
}
cm_yellow = vision.ColorModel{
	lefthue = 33,
	righthue = 85,
	minsat = 70,
	maxsat = 240,
	minval = 140,
	maxval = 240,
}
cm_black = vision.ColorModel{
	lefthue = 0,
	righthue = 360,
	minsat = 0,
	maxsat = 255,
	minval = 0,
	maxval = 50
}

gip = vision.GridImageProcessor(8, 5)
gip:addColorModel(cm_green)
gip:addColorModel(cm_red)
gip:addColorModel(cm_yellow)
gip:addColorModel(cm_black)

bip = vision.BlobImageProcessor(1, 5, 5)
bip:addColorModel(cm_black)

function vtest(cm)
	cm = cm or cm_green
	
	for i=1,3 do camera:readImage() end
	
	local image = camera:readImage()
	gip:processImage(image)
	
	for x=0,7 do
		for y=0,3 do
			local count = gip:getCount(x, y, cm)
			if count > 0 then
				print(x .. "," .. y .. " " .. count)
			end
		end
	end
	print("Done")
end

function btest()
	local image = camera:readImage()
	bip:processImage(image)
	
	local count = bip:getBlobCount()
	print("Count", count)
	for i=0,count-1 do
		print(bip:getBlob(i))
	end
end

