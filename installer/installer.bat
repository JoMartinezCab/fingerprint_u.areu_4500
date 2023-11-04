@echo off

call :main

pause
exit /b

:check_OS

    if "%OS%"=="Windows_NT" (
        echo Windows
    ) else (
        echo Linux
    )

    exit /b

:main
    call :check_OS

    exit /b