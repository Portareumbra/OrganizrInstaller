@ECHO off
title Oraganizr Windows Installer
COLOR 03
ECHO      ___           ___                  
ECHO     /  /\         /  /\           ___   
ECHO    /  /::\       /  /:/_         /__/\  
ECHO   /  /:/\:\     /  /:/ /\        \__\:\ 
ECHO  /  /:/  \:\   /  /:/ /:/_       /  /::\
ECHO /__/:/ \__\:\ /__/:/ /:/ /\   __/  /:/\/
ECHO \  \:\ /  /:/ \  \:\/:/ /:/  /__/\/:/
ECHO  \  \:\  /:/   \  \::/ /:/   \  \::/    
ECHO   \  \:\/:/     \  \:\/:/     \  \:\    
ECHO    \  \::/       \  \::/       \__\/    
ECHO     \__\/         \__\/             ~~ v0.7.0 Beta
ECHO.      
pause
ECHO.
SET nginx_v=1.12.2
SET php_v=7.2.1
SET nssm_v=2.24-101
SET vcr_v=2017
CD %~dp0
ECHO Where do you want to install Nginx? e.g 'c:\nginx'
SET /p nginx_loc=
ECHO.
ECHO 1. Downloading Nginx %nginx_v%
powershell -Command "(New-Object Net.WebClient).DownloadFile('http://nginx.org/download/nginx-1.12.2.zip', 'nginx.zip')"
powershell -Command "Invoke-WebRequest http://nginx.org/download/nginx-1.12.2.zip -OutFile nginx.zip"
ECHO.    Done!

ECHO 2. Downloading PHP   %php_v%
powershell -Command "(New-Object Net.WebClient).DownloadFile('http://windows.php.net/downloads/releases/php-7.2.1-nts-Win32-VC15-x64.zip', 'php.zip')"
powershell -Command "Invoke-WebRequest http://windows.php.net/downloads/releases/php-7.2.1-nts-Win32-VC15-x64.zip -OutFile php.zip"
ECHO.    Done!

ECHO 3. Downloading NSSM  %nssm_v%
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://nssm.cc/ci/nssm-2.24-101-g897c7ad.zip', 'nssm.zip')"
powershell -Command "Invoke-WebRequest https://nssm.cc/ci/nssm-2.24-101-g897c7ad.zip -OutFile nssm.zip"
ECHO.    Done!

ECHO 4. Downloading Visual C++ Redistributable for Visual Studio %vcr_v%
powershell -Command "Invoke-WebRequest https://download.microsoft.com/download/3/b/f/3bf6e759-c555-4595-8973-86b7b4312927/vc_redist.x64.exe -OutFile vc_redist.x64.exe"
ECHO.    Done!

ECHO.
ECHO 1. Unziping Nginx
powershell.exe -nologo -noprofile -command "& { Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::ExtractToDirectory('nginx.zip', '.'); }"
ECHO.    Done!

ECHO 2. Unziping PHP
powershell.exe -nologo -noprofile -command "& { Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::ExtractToDirectory('php.zip', 'php'); }"
ECHO.    Done!

ECHO 3. Unziping NSM
powershell.exe -nologo -noprofile -command "& { Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::ExtractToDirectory('nssm.zip', '.'); }"
ECHO.    Done!

ECHO.
ECHO Moving Nginx and PHP to destination
ECHO.
MOVE %~dp0nginx-* nginx
MOVE %~dp0nginx %nginx_loc%
MOVE %~dp0nssm-* nssm
MOVE %~dp0php %nginx_loc%\php

ECHO.
ECHO Moving NSSM to destination
ECHO.
MOVE %~dp0nssm\win64\nssm.exe C:\Windows\System32


ECHO.
ECHO Download Completed...

ECHO.
ECHO Creating Nginx service
ECHO.
ECHO In order to save and reload Nginx configuration, you need to run the NGINX service as the currently logged in user
ECHO Username: %username%
set /p pass=" Password: "
ECHO.  
NSSM install NGINX %nginx_loc%\nginx.exe
NSSM set NGINX ObjectName %userdomain%\%username% %pass%
NSSM start NGINX
NSSM restart NGINX


ECHO.
ECHO Installing Visual C++ Redistributable for Visual Studio 2017 [PHP 7+ requirement]
vc_redist.x64.exe /q /norestart
ECHO.
ECHO Creating PHP service
ECHO.
NSSM install PHP %nginx_loc%\php\php-cgi.exe
NSSM set PHP AppParameters -b 127.0.0.1:9000
NSSM set PHP ObjectName %userdomain%\%username% %pass%
NSSM start PHP
NSSM restart PHP

ECHO.
ECHO Downloading Organizr Master
ECHO.
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://github.com/causefx/Organizr/archive/master.zip', 'master.zip')"
powershell -Command "Invoke-WebRequest https://github.com/causefx/Organizr/archive/master.zip -OutFile master.zip"
powershell.exe -nologo -noprofile -command "& { Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::ExtractToDirectory('master.zip', '.'); }"
MOVE %~dp0Organizr-master organizr
DEL /s /q %~dp0master.zip
xcopy /e /i /y /s organizr %nginx_loc%\html\organizr
RMDIR /s /q organizr

ECHO.
ECHO #############################
ECHO Updating Nginx and PHP config
ECHO #############################
ECHO.
COPY %~dp0config\nginx.conf %nginx_loc%\conf\nginx.conf
CD %nginx_loc%
nginx -s reload
CD %~dp0
COPY %~dp0config\php.ini %nginx_loc%\php\php.ini
CD %nginx_loc%
nginx -s reload
CD %~dp0
NSSM restart PHP
NSSM restart NGINX
ECHO.
timeout /t 4 /nobreak
SET /p "=Nginx status : " <nul
NSSM status NGINX
SET /p "=PHP   status : " <nul
NSSM status PHP
ECHO.
ECHO ########## Installation Completed ##########
ECHO.
SET /p "=To open Organizr [http://localhost] " <nul
pause
START http://localhost
ECHO.
ECHO ############################
ECHO Cleaning up downloaded Files
ECHO ############################
ECHO.
DEL /s /q %~dp0nginx.zip >nul 2>&1
ECHO nginx.zip      DELETED
DEL /s /q %~dp0php.zip >nul 2>&1
ECHO php.zip        DELETED
DEL /s /q %~dp0nssm.zip >nul 2>&1
ECHO nssm.zip       DELETED
DEL /s /q %~dp0vc_redist.x64.exe >nul 2>&1
ECHO vc_redist.exe  DELETED
RMDIR /s /q nssm >nul 2>&1
ECHO nssm directory REMOVED 
ECHO.
ECHO Done!
ECHO.
SET /p "=Exit: " <nul
pause
