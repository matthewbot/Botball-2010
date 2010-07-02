#ifndef MB_VISION_BLOBIMAGEPROCESSOR_H
#define MB_VISION_BLOBIMAGEPROCESSOR_H

#include "Image.h"
#include "ColorModel.h"
#include <vector>

struct Blob {
	int x, y, w, h;
};

class BlobImageProcessor {
	public:
		BlobImageProcessor(int maxgapdist, int minsegmentsize, int minblobheight, bool debug=false);
		
		void addColorModel(ColorModel *model); // keeps a pointer internally
		void processImage(const Image &image);
		
		typedef std::vector<Blob> BlobList;
		const BlobList &getBlobs() const { return blobs; }
		
	private:
		int maxgapdist, minsegmentsize, minblobheight;
		bool debug;
		BlobList blobs;
		
		typedef std::vector<ColorModel *> ColorModelList;
		ColorModelList models;
		
		// --- helper functions ---
		
		bool checkModels(const HSVPixel &pixel) const;
		
		struct Segment {
			int start, end;
		};
		typedef std::vector<Segment> SegmentList;
		SegmentList getSegments(int y, const Image &image) const;
		
		BlobList::iterator matchSegment(const Segment &segment, BlobList::iterator begin, BlobList::iterator end) const;
};

#endif

