#include <windows.h>
#include <string>
#include <stdexcept>
#include <fstream>
#include <sstream>
#include <stdio.h>
#include <iostream>

#include "lua.hpp"

#define DEBUG_MSG(msg) std::cout << msg << std::endl;

std::string getExecutablePath()
{
#ifdef WIN32
  char pBuf[FILENAME_MAX];

  int bytes = GetModuleFileName(NULL, pBuf, FILENAME_MAX);
  if (bytes == 0) {
    DEBUG_MSG("[ERROR] Cannot retrieve executable path.");
    return std::string();
  }

  std::string path = pBuf;
  int index = path.rfind("\\");
  path = path.substr(0, index);

  // logINFO("Found VBSSim3 root path: " + path);
  return path;
#else
  DEBUG_MSG("[ERROR] getExecutablePath is not implemented.");
  return "";
#endif
}

int main(int argc, char *argv[]) {
	DEBUG_MSG("Hello world!");

  std::string path = getExecutablePath();
  DEBUG_MSG("Executable path: "<<path)

  lua_State* state = luaL_newstate();
  DEBUG_MSG("Lua state opened.")

  // Assign panic function:
  // lua_atpanic (_state, panic_handler);

  DEBUG_MSG("Opening base libraries...");
  luaL_openlibs(state);

  // Set the root path:
  lua_pushstring(state, path.c_str());
  lua_setglobal(state, "root_path");

  // Execute the entry point:
  std::string mainfile = path + "\\run_app.lua";
  DEBUG_MSG("Executing entry point: "<<mainfile);

  // Load the main file:
  if (luaL_loadfile(state, mainfile.c_str()) != 0)
  {
    DEBUG_MSG("[ERROR] During loading of file " << mainfile << ":\n" << lua_tostring(state, -1));
    return 1;
  }

  // push the arguments:
  for(int i = 1; i<argc; ++i)
  {
  	lua_pushstring(state, argv[i]);
  }

  // Now call the script (argc-1 arguments, 1 result)
  /* do the call  */
  if (lua_pcall(state, argc-1, 0, 0) != 0) {
  	 DEBUG_MSG("[ERROR] running app: " << lua_tostring(state, -1));
  	 return 1;
  }       

  DEBUG_MSG("Closing lua state");
	lua_close(state);

  DEBUG_MSG("Execution done.");

	return 0;
};
