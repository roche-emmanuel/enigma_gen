@echo off

REM Use default build tools is not provided:
if not DEFINED BUILDTOOLS_SETUP (
	echo Using default buildtools.
	set BUILDTOOLS_SETUP="C:\Program Files (x86)\Microsoft Visual C++ Build Tools\vcbuildtools.bat"
)

REM Use current dir as root if not provided:
if not DEFINED PROJ_DIR (
	echo Using default simcore root path: %~dp0..
	set PROJ_DIR=%~dp0..
	REM echo Using default simcore root path: %PROJ_DIR%
)

REM Use the default dependencies path if not provided:
if not DEFINED DEPS_DIR (
	set DEPS_DIR=%PROJ_DIR%\deps
	REM echo Using default dependency path: %DEPS_DIR%
)

REM define the tools used here:
set JOM_PATH=%PROJ_DIR%\tools\windows\jom-1.1.0
set JOM=%JOM_PATH%\jom.exe
set CMAKE=%PROJ_DIR%\tools\windows\cmake-3.5.0\bin\cmake.exe

if "%~1" neq "" (
  2>nul >nul findstr /rc:"^ *:%~1\>" "%~f0" && (
    shift /1
    goto %1
  ) || (
    >&2 echo ERROR: routine %~1 not found
  )
) else >&2 echo ERROR: missing routine
exit /b

@echo on


:check_dependencies
	set flavor=%~1

	echo Loading build tools for %flavor% compilation...
	echo BUILDTOOLS setup file: %BUILDTOOLS_SETUP%

	if "%flavor%" == "msvc32" (
		call %BUILDTOOLS_SETUP% amd64_x86
	) else (
		call %BUILDTOOLS_SETUP% amd64
	)

	echo Checking dependencies for %flavor%...
	REM echo Current user is: %USERNAME%

	set cdir=%cd%

	rem call %PROJ_DIR%\scripts\deps.bat check_geolib %flavor%
	rem call %PROJ_DIR%\scripts\deps.bat check_boost %flavor%
	rem call %PROJ_DIR%\scripts\deps.bat check_dxsdk %flavor%
	rem call %PROJ_DIR%\scripts\deps.bat check_fusion %flavor%
	rem call %PROJ_DIR%\scripts\deps.bat check_luajit %flavor%
	rem call %PROJ_DIR%\scripts\deps.bat check_cef %flavor%

	cd /d "%cdir%"
exit /b


REM Method used to build the SimCore project

:build
	set flavor=%~1
	echo Building %flavor% flavor of project
	
	set am=64
	if "%flavor%"=="msvc32" (
		set am=32
	)
	

	rem echo CMake version is: 
	%CMAKE% --version
	echo PATH is: %PATH%

	call:check_dependencies %flavor%

	echo Project root dir is %PROJ_DIR%

	rem Create the build dir if necessary:
	if not exist %PROJ_DIR%\build (
		mkdir "%PROJ_DIR%\build"
	)

	if not exist %PROJ_DIR%\build\%flavor% (
		mkdir "%PROJ_DIR%\build\%flavor%"
	)

	cd /d "%PROJ_DIR%\build\%flavor%"

	REM Configuration entries:
	set GENERATOR="NMake Makefiles JOM"
	REM set GENERATOR="NMake Makefiles"
	
	set SCFLAGS=-DFLAVOR=WIN%am%
	rem set SCFLAGS=%SCFLAGS% -DDOXYGEN_PATH=%DOXYGEN%
	rem set SCFLAGS=%SCFLAGS% -DSGT_PATH=%SGT%
	rem set SCFLAGS=%SCFLAGS% -DUPX_PATH=%UPX_PATH%
	set SCFLAGS=%SCFLAGS% -DCMAKE_BUILD_TYPE=Release
	set SCFLAGS=%SCFLAGS% -DCMAKE_INSTALL_PREFIX=%PROJ_DIR%\software\bin\%flavor%
	set SCFLAGS=%SCFLAGS% -DLUA_DIR=%DEPS_DIR%\%flavor%\%dep_luajit%

	rem rem We need to ensure that jom is in the path as cmake
	rem will try to use it when testing the environment, and thus will
	rem fail if JOM is not found:
	set PREV_PATH=%PATH%
	set PATH=%JOM_PATH%;%PATH%

	REM Configure the build:
	echo Cmake flags: %SCFLAGS%
	echo Build folder: %cd%
	%CMAKE% -G %GENERATOR% %SCFLAGS% %PROJ_DIR%
	if %ERRORLEVEL% GEQ 1 exit 1

	REM now make the build:
	REM %JOM% /K /S /j 8 /NOLOGO VERBOSE=1
	%JOM% /K /S /j 8 /NOLOGO
	if %ERRORLEVEL% GEQ 1 exit 1

	REM perform installation:
	%JOM% /K /S /j 8 /NOLOGO install
	if %ERRORLEVEL% GEQ 1 exit 1

	set PATH=%PREV_PATH%

	cd /d "%PROJ_DIR%"
exit /b

