#include "bindings.h"
#include <lua.hpp>

using namespace std;

extern "C" int luaopen_mb_rawvision(lua_State *L) {
	lua_newtable(L);
	luaL_register(L, NULL, luafuncs);
	
	return 1;
}

