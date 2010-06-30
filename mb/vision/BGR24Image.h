#ifndef MB_VISION_BGRIMAGE_H
#define MB_VISION_BGRIMAGE_H

#include "Image.h"
#include <stdint.h>

class BGR24Image : public Image {
	public:
		BGR24Image(int width, int height);
		
		virtual Pixel getPixel(int x, int y) const;
		virtual void setPixel(int x, int y, const Pixel &pixel);
		
	private:
		int getOffset(int x, int y) const;
};

#endif

