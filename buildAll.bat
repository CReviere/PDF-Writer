@echo off
:: Build PDF-Writer for x64 and x86, debug and non-debug
:: Assumes you are using a shell which has `sed` and `cmake` in its PATH 
::
:: Author: cr

:: find vcvarsall for VS2017
if exist "C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" (
  set VCVARS="C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\VC\Auxiliary\Build\vcvarsall.bat"
)
if exist "C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\VC\Auxiliary\Build\vcvarsall.bat" (
  set VCVARS="C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\VC\Auxiliary\Build\vcvarsall.bat"
)

:: build for x86
setlocal
mkdir build32 && cd build32
cmake -G "Visual Studio 15 2017" -DPDFHUMMUS_NO_AES=true -DUNICODE_CHARSET=true -DMSVC_USE_STATIC_RUNTIME=true ..

sed -i 's/\/MD/\/MT/g' CMakeCache.txt

call %VCVARS% x86
for %%c in (Debug Release) do (
  msbuild "PDFHUMMUS.sln" /t:Build /v:quiet /p:Configuration=%%c /p:Platform=Win32 /m
)
endlocal

:: build for x64
setlocal
mkdir build64 && cd build64
cmake -G "Visual Studio 15 2017 Win64" -DPDFHUMMUS_NO_AES=true -DUNICODE_CHARSET=true -DMSVC_USE_STATIC_RUNTIME=true ..

sed -i 's/\/MD/\/MT/g' CMakeCache.txt

call %VCVARS% x64
for %%c in (Debug Release) do (
  msbuild "PDFHUMMUS.sln" /t:Build /v:quiet /p:Configuration=%%c /p:Platform=x64 /m
)
endlocal
