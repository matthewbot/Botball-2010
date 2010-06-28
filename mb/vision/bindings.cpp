#include "bindings.h"
#include "Camera.h"
#include "BGR24Image.h"
#include <lua.hpp>
#include <stdexcept>
#include <string>

using namespace std;

static int lua_open_camera(lua_State *L);
static int lua_close_camera(lua_State *L);
static int lua_read_image(lua_State *L);
static int lua_free_image(lua_State *L);
static int lua_get_pixel(lua_State *L);

const luaL_Reg luafuncs[] = {
	{"open_camera", lua_open_camera},
	{"read_image", lua_read_image},
	{"get_pixel", lua_get_pixel},
	
	{NULL, NULL}
};

static int lua_open_camera(lua_State *L) {
	int width = luaL_checkint(L, 1);
	int height = luaL_checkint(L, 2);

	Camera *cam;
	try {
		void *userdata = lua_newuserdata(L, sizeof(Camera));
		cam = new (userdata) Camera(width, height);
	} catch (runtime_error &err) {
		return luaL_error(L, "%s", err.what());
	}

	if (luaL_newmetatable(L, "mb_vision_camera")) {
		lua_pushcfunction(L, lua_close_camera);
		lua_setfield(L, 4, "__gc");
	}
	lua_setmetatable(L, 3);
	
	return 1;
}

static int lua_close_camera(lua_State *L) {
	Camera *cam = (Camera *)luaL_checkudata(L, 1, "mb_vision_camera");
	cam->~Camera();
	
	return 0;
}

static int lua_read_image(lua_State *L) {
	Camera *cam = (Camera *)luaL_checkudata(L, 1, "mb_vision_camera");
	void *userdata = lua_newuserdata(L, sizeof(BGR24Image));
	Image *image = new (userdata) BGR24Image(cam->getWidth(), cam->getHeight());
	
	if (luaL_newmetatable(L, "mb_vision_image")) {
		lua_pushcfunction(L, lua_free_image);
		lua_setfield(L, 3, "__gc");
	}
	lua_setmetatable(L, 2);
	
	try {
		cam->readImage(image->getBuffer());
	} catch (runtime_error &err) {
		return luaL_error(L, "%s", err.what());
	}
	
	return 1;
}

static int lua_free_image(lua_State *L) {
	Image *image = (Image *)luaL_checkudata(L, 1, "mb_vision_image");
	image->~Image();
	
	return 0;
}

static int lua_get_pixel(lua_State *L) {
	Image *image = (Image *)luaL_checkudata(L, 1, "mb_vision_image");
	int x = luaL_checkint(L, 2);
	int y = luaL_checkint(L, 3);
	
	Pixel pixel = image->getPixel(x, y);
	
	lua_pushinteger(L, pixel.r);
	lua_pushinteger(L, pixel.g);
	lua_pushinteger(L, pixel.b);
	
	return 3;
}

