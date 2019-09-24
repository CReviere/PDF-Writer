@echo off
:: Build PDF-Writer for x64 and x86, debug and non-debug
::
:: Author: cr

setlocal

if exist "C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" (
  set vcvars="C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\VC\Auxiliary\Build\vcvarsall.bat"
)
if exist "C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\VC\Auxiliary\Build\vcvarsall.bat" (
  set vcvars="C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\VC\Auxiliary\Build\vcvarsall.bat"
)
if exist "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvarsall.bat" (
  set vcvars="C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvarsall.bat"
)

if not defined logfile set logfile=..\build.log
if exist %logfile% del %logfile%

where cmake >nul 2>nul
if errorlevel 1 (
  if not exist "C:\Program Files\CMake\bin\cmake.exe" echo CMake must be installed to continue && exit
  set cmakecmd="C:\Program Files\CMake\bin\cmake.exe"
) else (set cmakecmd=cmake)

echo Building PDF Writer library

if exist build32 (
  echo Cleaning up leftovers from previous builds
  @rd /s /q build32
  if exist build64 @rd /s /q build64
)

cd "%~dp0"

setlocal
echo Generating x86 build files
mkdir build32 && cd build32
%cmakecmd% -G "Visual Studio 15 2017" -DPDFHUMMUS_NO_AES=true -DUNICODE_CHARSET=true -DMSVC_USE_STATIC_RUNTIME=true .. >> %logfile%
if errorlevel 1 goto error

powershell -Command "(gc CMakeCache.txt) -replace '/MD', '/MT' | Out-File -encoding ASCII CMakeCache.txt"

call %vcvars% x86 >> %logfile%
for %%c in (Debug Release) do (
  echo Building library for x86 - %%c
  msbuild "PDFHUMMUS.sln" -t:Build -p:Configuration=%%c -p:Platform=Win32 /m >> %logfile%
  if errorlevel 1 goto error
)
endlocal

setlocal
echo Generating x64 build files
mkdir build64 && cd build64
%cmakecmd% -G "Visual Studio 15 2017 Win64" -DPDFHUMMUS_NO_AES=true -DUNICODE_CHARSET=true -DMSVC_USE_STATIC_RUNTIME=true .. >> %logfile%
if errorlevel 1 goto error

powershell -Command "(gc CMakeCache.txt) -replace '/MD', '/MT' | Out-File -encoding ASCII CMakeCache.txt"

call %vcvars% x64 >> %logfile%
for %%c in (Debug Release) do (
  echo Building library for x64 - %%c
  msbuild "PDFHUMMUS.sln" /t:Build /v:quiet /p:Configuration=%%c /p:Platform=x64 /m >> %logfile%
  if errorlevel 1 goto error
)
endlocal

echo Finished building PDF Writer library

endlocal
goto :eof

:error
  echo 'PDF-Writer' build failed - check build.log for more details
  