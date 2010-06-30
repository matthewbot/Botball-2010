vision = require "mb.vision"

camera = vision.Camera()
cm = vision.ColorModel{
	lefthue = 0,
	righthue = 360,
	minsat = 100,
	minval = 100
}
gip = vision.GridImageProcessor(4, 2)
gip:addColorModel(cm)

function vtest()
	local image = camera:readImage()
	gip:processImage(image)
	
	for y=0,1 do
		local buf = ""
		for x=0,3 do
			buf = buf .. gip:getCount(x, y, cm) .. " "
		end
		print(buf)
	end
end

