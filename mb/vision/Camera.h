#ifndef MB_VISION_CAMERA_H
#define MB_VISION_CAMERA_H

#include <string>

class Camera {
	public:
		Camera(int width=160, int height=120, std::string path="/dev/video0");
		~Camera();
		
	private:
		int width, height;
		int fd;
};

#endif
