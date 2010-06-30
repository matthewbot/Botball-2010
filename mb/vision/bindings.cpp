#include "bindings.h"
#include "Camera.h"
#include "BGR24Image.h"
#include "GridImageProcessor.h"
#include "ColorModel.h"
#include <lua.hpp>
#include <stdexcept>
#include <string>

using namespace std;

static int camera_new(lua_State *L);
static int camera_read_image(lua_State *L);
static int image_get_pixel(lua_State *L);
static int color_model_new(lua_State *L);
static int gip_new(lua_State *L);
static int gip_add_color_model(lua_State *L);
static int gip_process_image(lua_State *L);
static int gip_get_count(lua_State *L);

template <typename T> static int lua_destructor(lua_State *L) {
	T *obj = (T *)lua_touserdata(L, 1);
	if (obj)
		obj->~T();
	return 0;
}

static void setup_metatable(lua_State *L, int idx, const char *metatablename, lua_CFunction destructor) {
	if (luaL_newmetatable(L, metatablename)) {
		lua_pushcfunction(L, destructor);
		lua_setfield(L, -2, "__gc");
	}
	lua_setmetatable(L, idx);
}

const luaL_Reg luafuncs[] = {
	{"camera_new", camera_new},
	{"camera_read_image", camera_read_image},
	{"image_get_pixel", image_get_pixel},
	{"color_model_new", color_model_new},
	{"gip_new", gip_new},
	{"gip_add_color_model", gip_add_color_model},
	{"gip_process_image", gip_process_image},
	{"gip_get_count", gip_get_count},
	{NULL, NULL}
};

static int camera_new(lua_State *L) {
	int width = luaL_checkint(L, 1);
	int height = luaL_checkint(L, 2);
	string path = lua_tostring(L, 3);

	Camera *cam;
	try {
		void *userdata = lua_newuserdata(L, sizeof(Camera));
		cam = new (userdata) Camera(width, height, path);
	} catch (runtime_error &err) {
		return luaL_error(L, "%s", err.what());
	}

	setup_metatable(L, 4, "mb_vision_camera", lua_destructor<Camera>);
	
	return 1;
}

static int camera_read_image(lua_State *L) {
	Camera *cam = (Camera *)luaL_checkudata(L, 1, "mb_vision_camera");
	void *userdata = lua_newuserdata(L, sizeof(BGR24Image));
	Image *image = new (userdata) BGR24Image(cam->getWidth(), cam->getHeight());
	
	setup_metatable(L, 2, "mb_vision_image", lua_destructor<Image>);
	
	try {
		cam->readImage(image->getBuffer());
	} catch (runtime_error &err) {
		return luaL_error(L, "%s", err.what());
	}
	
	return 1;
}

static int image_get_pixel(lua_State *L) {
	Image *image = (Image *)luaL_checkudata(L, 1, "mb_vision_image");
	int x = luaL_checkint(L, 2);
	int y = luaL_checkint(L, 3);
	
	Pixel pixel = image->getPixel(x, y);
	
	lua_pushinteger(L, pixel.r);
	lua_pushinteger(L, pixel.g);
	lua_pushinteger(L, pixel.b);
	
	return 3;
}

static int color_model_new(lua_State *L) {
	uint16_t lefthue = luaL_checkint(L, 1);
	uint16_t righthue = luaL_checkint(L, 2);
	uint8_t minsat = luaL_checkint(L, 3);
	uint8_t minval = luaL_checkint(L, 4);
	uint8_t maxsat = luaL_checkint(L, 5);
	uint8_t maxval = luaL_checkint(L, 6);
	lua_settop(L, 0);
	
	void *userdata = lua_newuserdata(L, sizeof(ColorModel));
	new (userdata) ColorModel(lefthue, righthue, minsat, minval, maxsat, maxval);
	
	setup_metatable(L, 1, "mb_vision_colormodel", lua_destructor<ColorModel>);
	
	return 1;
}

static int gip_new(lua_State *L) {
	int w = luaL_checkint(L, 1);
	int h = luaL_checkint(L, 2);
	
	void *userdata = lua_newuserdata(L, sizeof(GridImageProcessor));
	new (userdata) GridImageProcessor(w, h);
	
	setup_metatable(L, 3, "mb_vision_gridimageprocessor", lua_destructor<GridImageProcessor>);
	
	return 1;
}

static int gip_add_color_model(lua_State *L) {
	GridImageProcessor *gip = (GridImageProcessor *)luaL_checkudata(L, 1, "mb_vision_gridimageprocessor");
	ColorModel *cm = (ColorModel *)luaL_checkudata(L, 2, "mb_vision_colormodel");
	
	gip->addColorModel(cm);
	
	return 0;
}

static int gip_process_image(lua_State *L) {
	GridImageProcessor *gip = (GridImageProcessor *)luaL_checkudata(L, 1, "mb_vision_gridimageprocessor");
	Image *image = (Image *)luaL_checkudata(L, 2, "mb_vision_image");
	
	gip->processImage(*image);
	
	return 0;
}

static int gip_get_count(lua_State *L) {
	GridImageProcessor *gip = (GridImageProcessor *)luaL_checkudata(L, 1, "mb_vision_gridimageprocessor");
	int x = luaL_checkint(L, 2);
	int y = luaL_checkint(L, 3);
	ColorModel *cm = (ColorModel *)luaL_checkudata(L, 4, "mb_vision_colormodel");
	
	int count = gip->getCount(x, y, cm);
	
	lua_pushinteger(L, count);
	return 1;	
}

