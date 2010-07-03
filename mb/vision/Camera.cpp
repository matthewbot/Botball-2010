#include "Camera.h"
#include <string>
#include <stdexcept>
#include <cstring>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <linux/videodev2.h>
#include <errno.h>

using namespace std;

static string stringerr();

Camera::Camera(int width, int height, string path) : width(width), height(height) {
	fd = open(path.c_str(), O_RDWR);
	if (fd < 0)
		throw runtime_error("Failed to open camera: " + stringerr());
		
	struct v4l2_format fmt;
	memset(&fmt, '\0', sizeof(fmt));
	fmt.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
	fmt.fmt.pix.width = width;
	fmt.fmt.pix.height = height;
	fmt.fmt.pix.pixelformat = V4L2_PIX_FMT_BGR24;
	fmt.fmt.pix.field = V4L2_FIELD_INTERLACED;
	
	if (ioctl(fd, VIDIOC_S_FMT, &fmt) != 0) {
		::close(fd);
		throw runtime_error("Failed to set camera video format: " + stringerr());
	}
}

Camera::~Camera() {
	close();
}

void Camera::close() {
	if (fd >= 0) {
		::close(fd);
		fd = -1;
	}
}

void Camera::readImage(uint8_t *buffer) {
	if (fd < 0)
		throw runtime_error("Can't read from a closed camera!");

	int length = width*height*3;
	while (length > 0) {
		int got = read(fd, buffer, length);
		if (got == -1)
			throw runtime_error("Failed to read from camera: " + stringerr());
		length -= got;
		buffer += got;
	}
}

static string stringerr() {
	return string(strerror(errno));
}

