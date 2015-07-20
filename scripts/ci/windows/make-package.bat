@echo off
rem This batch file builds LASzip for VS2013 x86 and x64

if "%1"=="" goto usage

set PROJECT_NAME=LASzip

rem For devenv.exe
set PATH=%PATH%;"C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\IDE"

set SCRIPT_DIR=%~dp0

pushd .
cd %SCRIPT_DIR%..\..\..
set PROJECT_SOURCE_DIR=%CD%
popd

pushd .
cd %PROJECT_SOURCE_DIR%\..
set DEPLOY_DIR=%CD%
popd

set X86_DEPLOY_DIR=%DEPLOY_DIR%\%PROJECT_NAME%-x86
set X64_DEPLOY_DIR=%DEPLOY_DIR%\%PROJECT_NAME%-x64

IF NOT EXIST %X64_DEPLOY_DIR% (
	mkdir %X64_DEPLOY_DIR%
)

IF NOT EXIST %X86_DEPLOY_DIR% (
	mkdir %X86_DEPLOY_DIR%
)

pushd .

cd %X64_DEPLOY_DIR%
cmake -G "Visual Studio 12 2013 Win64" ^
-DCMAKE_INSTALL_PREFIX=x64\vc12 ^
%PROJECT_SOURCE_DIR%
if %errorlevel% neq 0 exit /b %errorlevel%

devenv %PROJECT_NAME%.sln /build Debug /project INSTALL
if %errorlevel% neq 0 exit /b %errorlevel%

devenv %PROJECT_NAME%.sln /build Release /project INSTALL
if %errorlevel% neq 0 exit /b %errorlevel%

popd

pushd .

cd %X86_DEPLOY_DIR%
cmake -G "Visual Studio 12 2013" ^
-DCMAKE_INSTALL_PREFIX=x86\vc12 ^
%PROJECT_SOURCE_DIR%
if %errorlevel% neq 0 exit /b %errorlevel%

devenv %PROJECT_NAME%.sln /build Debug /project INSTALL
if %errorlevel% neq 0 exit /b %errorlevel%

devenv %PROJECT_NAME%.sln /build Release /project INSTALL
if %errorlevel% neq 0 exit /b %errorlevel%

popd

pushd .

cd %X64_DEPLOY_DIR%

set PROJECT_INSTALL_DIR=%DEPLOY_DIR%\%PROJECT_NAME%-%1
set X64_INSTALL_DIR=%PROJECT_INSTALL_DIR%\x64\vc12
set X86_INSTALL_DIR=%PROJECT_INSTALL_DIR%\x86\vc12

mkdir %X64_INSTALL_DIR%
mkdir %X86_INSTALL_DIR%

xcopy /S /E /Q %X64_DEPLOY_DIR%\x64\vc12\include %PROJECT_INSTALL_DIR%\include /I
xcopy /S /E /Q %X64_DEPLOY_DIR%\x64\vc12\lib %X64_INSTALL_DIR%\lib /I
xcopy /S /E /Q %X64_DEPLOY_DIR%\x64\vc12\bin %X64_INSTALL_DIR%\bin /I
xcopy /S /E /Q %X86_DEPLOY_DIR%\x86\vc12\lib %X86_INSTALL_DIR%\lib /I
xcopy /S /E /Q %X86_DEPLOY_DIR%\x86\vc12\bin %X86_INSTALL_DIR%\bin /I

popd

rem Clean-up deployment directories
IF EXIST %X64_DEPLOY_DIR% (
	rmdir %X64_DEPLOY_DIR% /s /q
)

IF EXIST %X86_DEPLOY_DIR% (
	rmdir %X86_DEPLOY_DIR% /s /q
)

"C:\Program Files\7-Zip\7z.exe" a -r -tzip %PROJECT_INSTALL_DIR%.zip %PROJECT_INSTALL_DIR%

goto :eof

:usage
echo Usage: make-package [version-string]
goto :eof

@echo on