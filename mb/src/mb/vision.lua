local rawvision = require "mb.rawvision"
local task = require "cbclua.task"

Camera = create_class "Camera"

function Camera:construct(width, height, path)
	if not width then
		width = 160
		height = 120
	end
	if not path then
		path = "/dev/video0"
	end
	
	self.obj = rawvision.camera_new(width, height, path)
end

function Camera:readImage()
	return Image(rawvision.camera_read_image(self.obj))
end

Image = create_class "Image"

function Image:construct(obj)
	self.obj = obj
end

function Image:getPixel(x, y)
	return rawvision.image_get_pixel(self.obj, x, y)
end

ColorModel = create_class "ColorModel"

function ColorModel:construct(args)
	self.obj = rawvision.color_model_new(args.lefthue, args.righthue, args.minsat, args.minval, args.maxsat or 255, args.maxval or 255)
end

GridImageProcessor = create_class "GridImageProcessor"

function GridImageProcessor:construct(w, h)
	self.obj = rawvision.gip_new(w, h)
end

function GridImageProcessor:addColorModel(model)
	rawvision.gip_add_color_model(self.obj, model.obj)
end

function GridImageProcessor:processImage(image)
	rawvision.gip_process_image(self.obj, image.obj)
end

function GridImageProcessor:getCount(x, y, model)
	return rawvision.gip_get_count(self.obj, x, y, model.obj)
end


