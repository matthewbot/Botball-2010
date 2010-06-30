#include "BGR24Image.h"

BGR24Image::BGR24Image(int width, int height)
: Image(width, height, width*height*3) { }

Pixel BGR24Image::getPixel(int x, int y) const {
	const uint8_t *pix = buf + getOffset(x, y);
	return Pixel(pix[2], pix[1], pix[0]);
}

void BGR24Image::setPixel(int x, int y, const Pixel &pixel) {
	uint8_t *pix = buf + getOffset(x, y);
	pix[0] = pixel.b;
	pix[1] = pixel.g;
	pix[2] = pixel.r;
}

int BGR24Image::getOffset(int x, int y) const {
	return (x + y*width)*3;
}

