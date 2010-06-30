#include "ColorModel.h"

ColorModel::ColorModel(uint16_t lefthue, uint16_t righthue, uint8_t minsat, uint8_t minval, uint8_t maxsat, uint8_t maxval)
: lefthue(lefthue), righthue(righthue), minsat(minsat), maxsat(maxsat), minval(minval), maxval(maxval) { }

ColorModel::ColorModel() 
: lefthue(0), righthue(0), minsat(0), maxsat(0), minval(0), maxval(0) { }

bool ColorModel::checkPixel(const HSVPixel &pixel) const {	
	if (pixel.s < minsat || pixel.s > maxsat)
		return false;
	
	if (pixel.v < minval || pixel.v > maxval)
		return false;

	return (lefthue < righthue) ^ (pixel.h < lefthue || pixel.h > righthue);
}

