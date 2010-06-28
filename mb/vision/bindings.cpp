#include "bindings.h"
#include "Camera.h"
#include <lua.hpp>
#include <stdexcept>
#include <string>

using namespace std;

static int lua_open_camera(lua_State *L);
static int lua_close_camera(lua_State *L);

const luaL_Reg luafuncs[] = {
	{"open_camera", lua_open_camera},
	
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

