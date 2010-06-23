#include <iostream>
#include <lua.hpp>

using namespace std;

extern "C" int luaopen_mb_vision(lua_State *L) {
	cout << "Hello World, from vision module!" << endl;
	
	return 1;
}
