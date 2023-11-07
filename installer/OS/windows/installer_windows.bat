@echo off
setlocal enabledelayedexpansion
    
call :main

pause
exit


:check_admin
    net session >nul 2>&1
    set adminStatus=%errorlevel%
        
exit /B


:enable_admin
    set /p answer=Para continuar debe Habilitar permisos de administrador ¿Desea continuar? (y/n): 
        
    if /i "%answer%"=="y" (
        NET FILE 1>NUL 2>NUL || (
            powershell -Command "Start-Process -Verb RunAs -FilePath '%~dpnx0' -ArgumentList 'am_admin'"
            exit
            )
        ) else if /i "%answer%"=="n" (
                call :close_proccess "No se han asignados privilegios de administrador."
            exit
        ) 

exit /b


:check_architecture

    reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && set systemArchitecture=x86 || set systemArchitecture=x64

exit /b


:unzip_sdk
    set "file=%~1"
    set "path=%~2"
    set "zip_file=%path%\%file%.zip"
    set "destination_path=%path%\%file%"

    echo Unzipping %file%.zip to %destination_path%...
    if not exist "%destination_path%" (
        mkdir "%destination_path%"
    )

    tar -xf "%zip_file%" -C "%destination_path%"

exit /b


:installer_fingerprint

    set "executable=%~1"
    
    echo %executable%

    echo Preparando la ejecución del programa
    start /WAIT "Instalation" "%executable%"
    echo El programa finalizo la ejecución.

exit /b


:close_proccess
    set "message=%1"
    echo message
    echo El terminal se cerrará en 5 segundos. Pulse cualquier tecla para cerrarlo inmediatamente.
    timeout /nobreak /t 5 >nul
    choice /n /c Y /t 0 /d Y >nul
exit /b


:start_process
    call :check_architecture %systemArchitecture%

    if /i %systemArchitecture% neq x86 if /i %systemArchitecture% neq x64 (
        call :close_proccess "Arquitectura de sistema desconocida. Imposible continuar con la instalación."
    )

    set "sdk_path=%~dp0sdk"

    set "zip_sdk=UareUWin300_20170223.1115_2"
    set "install_sdk=%sdk_path%\%zip_sdk%\SDK\%systemArchitecture%\setup.exe"
    
    call :unzip_sdk %zip_sdk% "%sdk_path%" 
    call :installer_fingerprint "%install_sdk%"


    set "zip_patch=SDKPatch"
    set "install_patch=%sdk_path%\%zip_patch%\%zip_patch%\dpb02_14_300_001_%systemArchitecture%.exe"

    call :unzip_sdk %zip_patch% "%sdk_path%"
    call :installer_fingerprint "%install_patch%" 

    java -classpath ".;C:\Program Files\DigitalPersona\U.areU SDK\Windows\Lib\Java\dpuareu.jar" -Djava.library.path="C:\Program Files\DigitalPersona\U.areU SDK\Windows\Lib\win32" UareUSampleJava

exit /b


:main

    title Fingerprint installer - Windows

    call :check_admin adminStatus
    
    if "%adminStatus%"=="0" (call:start_process) else (call:enable_admin)    

exit /b