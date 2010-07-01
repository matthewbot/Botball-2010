#include "BlobImageProcessor.h"
#include <algorithm>
#include <iostream>

using namespace std;

BlobImageProcessor::BlobImageProcessor(int maxgapdist, int minsegmentsize, int minblobheight, bool debug)
: maxgapdist(maxgapdist), minsegmentsize(minsegmentsize), minblobheight(minblobheight), debug(debug) { }

void BlobImageProcessor::addColorModel(ColorModel *model) {
	models.push_back(model);
}

void BlobImageProcessor::processImage(const Image &image) {
	blobs.clear();

	int y;
	BlobList activeblobs;
	
	for (y=0; y<image.getHeight(); y++) { // for each row
		SegmentList segments = getSegments(y, image); // find all the segments
		
		for (SegmentList::iterator segment = segments.begin(); segment != segments.end(); ++segment) { // for each segment
			BlobList::iterator mainblob = matchSegment(*segment, activeblobs.begin(), activeblobs.end());
			
			if (mainblob != activeblobs.end()) { // if the segment matches a blob
				mainblob->h = y - mainblob->y; // extend its height down to the current row
				if (segment->start < mainblob->x) // move its x position as needed
					mainblob->x = segment->start;
				if (segment->end > mainblob->x + mainblob->w) // recalculate its width as needed
					mainblob->w = segment->end - mainblob->x;
			
				BlobList::iterator mergeblob = mainblob+1;
				while ((mergeblob = matchSegment(*segment, mergeblob, activeblobs.end())) != activeblobs.end()) { // continue looking for more blobs
					 // if we match another blob
					if (mainblob->x + mainblob->w < mergeblob->x + mergeblob->w) // and it is wider than our main blob
						mainblob->w = mergeblob->x + mergeblob->w - mainblob->x; // extend our main blob
						
					mergeblob = activeblobs.erase(mergeblob); // remove the merged blob
				}
			} else { // segment doesn't match a blob
				Blob newblob; // make a new one
				newblob.x = segment->start;
				newblob.w = segment->end - segment->start;
				newblob.y = y;
				newblob.h = 1;
				
				activeblobs.push_back(newblob);
			}
		}
		
		for (BlobList::iterator blob = activeblobs.begin(); blob != activeblobs.end();) { // go through all of the active blobs
			if (blob->y + blob->h + maxgapdist < y) { // if there is too large of a gap
				if (blob->h > minblobheight) // if they're tall enough
					blobs.push_back(*blob); // keep it, copy it to the main blob list
				blob = activeblobs.erase(blob); // remove them from the active blob list
			} else
				++blob;
		}
	}
	
	blobs.insert(blobs.end(), activeblobs.begin(), activeblobs.end()); // copy all blobs that reached the bottom of the screen to the main blob list

	if (debug) {
		for (BlobList::iterator i = blobs.begin(); i != blobs.end(); ++i) {
			cout << "Blob at (" << i->x << "," << i->y << ") size " << i->w << "x" << i->h << endl;
		}
	}
}

BlobImageProcessor::BlobList::iterator BlobImageProcessor::matchSegment(const Segment &segment, BlobList::iterator blob, BlobList::iterator end) const {
	for (; blob != end; ++blob) {
		if (segment.start <= blob->x) {
			if (segment.end > blob->x)
				return blob;
		} else {
			if (segment.start <= blob->x + blob->w)
				return blob;
		}
	}
	
	return blob;	
}

BlobImageProcessor::SegmentList BlobImageProcessor::getSegments(int y, const Image &image) const {
	SegmentList segments;
	Segment cursegment = { -1, -1 };
	int gapcount;
	int x;
	
	for (x=0; x<image.getWidth(); x++) {
		HSVPixel pixel = image.getPixel(x, y);
		if (checkModels(pixel)) { // if the pixel is valid
			if (cursegment.start == -1) { // if its the first pixel in a row
				cursegment.start = x; // start a new segment
				if (debug)
					cout << "New segment starting at (" << x << "," << y << ")" << endl;
			}

			gapcount = 0; // any valid pixel resets the gap counter
		} else if (cursegment.start > 0) { // pixel not valid, but we're in a row
			if (++gapcount > maxgapdist) { // if we've exceeded the maximum gap count
				cursegment.end = x - maxgapdist; // set the end of the segment
				if (cursegment.end - cursegment.start >= minsegmentsize) { // if the segment is large enough
					segments.push_back(cursegment); // save it
					if (debug)
						cout << "segment saved, ends at " << cursegment.end << endl;
				} else {
					if (debug)
						cout << "segment rejected due to width (" << cursegment.end - cursegment.start << ")" << endl;
				}
				cursegment.start = -1;
			}
		}
	}
	
	// if a segment goes off the side of the image, but is wide enough
	if (cursegment.start > 0) {
		if (image.getWidth() - cursegment.start >= minsegmentsize) {
			cursegment.end = image.getWidth()-1-gapcount;
			segments.push_back(cursegment);
			if (debug)
				cout << "Saving segment, hit edge of screen" << endl;
		} else {
			if (debug)
				cout << "Segment hit edge of screen, rejected due to width (" << cursegment.end - cursegment.start << "(" << endl;
		}
	}
	
	return segments;
}

bool BlobImageProcessor::checkModels(const HSVPixel &pixel) const {
	for (ColorModelList::const_iterator i = models.begin(); i != models.end(); ++i) {
		if ((*i)->checkPixel(pixel))
			return true;
	}
	
	return false;
}
