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
	minsat = 150,
	minval = 100	
}
gip = vision.GridImageProcessor(8, 5)
gip:addColorModel(cm_green)
gip:addColorModel(cm_red)

function vtest(cm)
	cm = cm or cm_green
	local image = camera:readImage()
	gip:processImage(image)
	
	for x=0,7 do
		for y=0,3 do
			local count = gip:getCount(x, y, cm)
			if count > 15 then
				print(x .. "," .. y .. " " .. count)
			end
		end
	end
	print("Done")
end

