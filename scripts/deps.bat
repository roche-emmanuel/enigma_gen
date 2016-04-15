@echo off

set dep_boost=boost_1_59_0
set dep_luajit=LuaJIT-2.0.4

if "%~1" neq "" (
  2>nul >nul findstr /rc:"^ *:%~1\>" "%~f0" && (
    shift /1
    goto %1
  ) || (
    >&2 echo ERROR: routine %~1 not found
  )
) else >&2 echo ERROR: missing routine
exit /b


@REM Clear the given build directory
:clear_build_dir
	set bdir=%DEPS_DIR%\build\%~1%

	if exist %bdir% (
		echo Removing previous build folder for %~1
		@REM echo Cannot build boost! build folder already exists.
		@REM exit /b
		@REM del /s /f /q %bdir%\*.* > nul
		@REM for /f %%f in ('dir /ad /b %bdir%\') do rd /s /q %bdir%\%%f > nul
		rmdir /s /q %bdir%
	)
	
	rem Create the build dir if it doesn't exist yet:
	if not exist %DEPS_DIR%\build (
		mkdir "%DEPS_DIR%\build"
	)

	@REM Recreate the build folder:
	echo Creating build folder for %~1%
	cd /d "%DEPS_DIR%\build"
	mkdir %~1%
	cd %~1%
exit /b


:build_boost
	set flavor=%~1
	echo Building %dep_boost% on %flavor%

	@REM Remove the content of the previous build folder if any:
	call:clear_build_dir %dep_boost%

	echo Boost build dir is: %cd%

	set src=%DEPS_DIR%\sources\%dep_boost%.7z

	@REM First we need to extract the zip file in the build folder:
	echo Extracting boost sources...
	%UNZIP% x -o"%DEPS_DIR%\build" "%src%" > nul

	set bdir=%DEPS_DIR%\build\%dep_boost%
	cd /d "%bdir%"

	echo Running bootstrap...
	call bootstrap.bat

	set amodel=64
	if "%flavor%"=="msvc32" (
		set amodel=32
	)

	echo Address model: %amodel% bits
	set idir=%DEPS_DIR%\msvc%amodel%\%dep_boost%

	echo Running bjam, installing to %idir%...
	REM For static runtime linkage:
	call bjam --prefix="%idir%" -sNO_BZIP2=1 -d 2 toolset=msvc architecture=x86 address-model=%amodel% variant=release link=static threading=multi runtime-link=static install > build.log 2>&1
	
	REM For dynamic runtime linkage:
	REM call bjam --prefix="%idir%" -sNO_BZIP2=1 -d 2 toolset=msvc architecture=x86 address-model=%amodel% variant=release link=static threading=multi install > build.log 2>&1

	move "%idir%\include\boost-1_59\boost" "%idir%\include\"
	rmdir "%idir%\include\boost-1_59"

	echo Done building boost.
exit /b

:build_luajit
	set flavor=%~1
	echo Building %dep_luajit% on %flavor%

	@REM Remove the content of the previous build folder if any:
	call:clear_build_dir %dep_luajit%

	echo LuaJIT build dir is: %cd%

	set src=%DEPS_DIR%\sources\%dep_luajit%_MT.7z

	@REM First we need to extract the zip file in the build folder:
	echo Extracting LuaJIT sources...
	@REM echo %UNZIP% x -o"%DEPS_DIR%\build" "%src%"
	%UNZIP% x -o"%DEPS_DIR%\build" "%src%" > nul

	set bdir=%DEPS_DIR%\build\%dep_luajit%
	cd /d "%bdir%\src"

	call msvcbuild.bat

	set amodel=64
	if "%flavor%"=="msvc32" (
		set amodel=32
	)

	echo Address model: %amodel% bits
	set idir=%DEPS_DIR%\msvc%amodel%\%dep_luajit%

	REM md %idir%\include
	REM md %idir%\lib
	REM md %idir%\bin 

	robocopy . %idir%\include\ lauxlib.h lua.h lua.hpp luaconf.h luajit.h lualib.h
	robocopy . %idir%\lib\ lua51.lib
	robocopy . %idir%\bin\ luajit.exe lua51.dll 

	REM move "%idir%\include\boost-1_59\boost" "%idir%\include\"
	REM rmdir "%idir%\include\boost-1_59"

	echo Done building LuaJIT.
exit /b

:check_boost
	set folder=%~1

	set dpath=%DEPS_DIR%\%folder%\%dep_boost%
	echo Checking boost folder %dpath%...

	if not exist "%dpath%\" (
		call:build_boost %~1
	) else (
		echo Boost : OK
	)

	cd /d "%SC_DIR%"
exit /b

:check_luajit
	set folder=%~1
	
	set dpath=%DEPS_DIR%\%folder%\%dep_luajit%
	echo Checking LuaJIT folder %dpath%...

	if not exist "%dpath%\" (
		call:build_luajit %~1
	) else (
		echo LuaJIT : OK
	)

	cd /d "%SC_DIR%"
exit /b

