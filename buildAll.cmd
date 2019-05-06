@echo off
:: Build PDF-Writer for x64 and x86, debug and non-debug
::
:: Author: cr

:: find vcvarsall for VS2017
if exist "C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" (
  set vcvars="C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\VC\Auxiliary\Build\vcvarsall.bat"
)
if exist "C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\VC\Auxiliary\Build\vcvarsall.bat" (
  set vcvars="C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\VC\Auxiliary\Build\vcvarsall.bat"
)

where cmake >nul 2>nul
if errorlevel 1 (
  if not exist "C:\Program Files\CMake\bin\cmake.exe" echo CMake must be installed to continue && exit
  set cmakecmd="C:\Program Files\CMake\bin\cmake.exe"
) else (set cmakecmd=cmake)

:: build for x86
setlocal
mkdir build32 && cd build32
%cmakecmd% -G "Visual Studio 15 2017" -DPDFHUMMUS_NO_AES=true -DUNICODE_CHARSET=true -DMSVC_USE_STATIC_RUNTIME=true ..

::sed -i 's/\/MD/\/MT/g' CMakeCache.txt
powershell -Command "(gc CMakeCache.txt) -replace '/MD', '/MT' | Out-File -encoding ASCII CMakeCache.txt"

call %vcvars% x86
for %%c in (Debug Release) do (
  msbuild "PDFHUMMUS.sln" /t:Build /v:quiet /p:Configuration=%%c /p:Platform=Win32 /m
)
if errorlevel 1 goto error
endlocal

:: build for x64
setlocal
mkdir build64 && cd build64
%cmakecmd% -G "Visual Studio 15 2017 Win64" -DPDFHUMMUS_NO_AES=true -DUNICODE_CHARSET=true -DMSVC_USE_STATIC_RUNTIME=true ..

::sed -i 's/\/MD/\/MT/g' CMakeCache.txt
powershell -Command "(gc CMakeCache.txt) -replace '/MD', '/MT' | Out-File -encoding ASCII CMakeCache.txt"

call %vcvars% x64
for %%c in (Debug Release) do (
  msbuild "PDFHUMMUS.sln" /t:Build /v:quiet /p:Configuration=%%c /p:Platform=x64 /m
)
if errorlevel 1 goto error
endlocal

goto :eof

:error
  An error occurred, check the previous output to determine what went wrong