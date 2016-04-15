#include <windows.h>
#include <string>
#include <stdexcept>
#include <fstream>
#include <sstream>
#include <stdio.h>
#include <iostream>

#ifdef ENIGMAGEN_WINDOWS
int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nShowCmd) {
#else
int main(int argc, char *argv[]) {
#endif

	std::cout << "Hello world!" <<std::endl;
	return 0;
};
