@echo off

:-------------------------------------
    IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params= %*
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"

setlocal EnableDelayedExpansion

set "ODT_EXE="
set "BEST_A=0"
set "BEST_B=0"

for %%F in ("%~dp0files\officedeploymenttool_*-*.exe") do (
    set "NAME=%%~nF"
    set "VER=!NAME:officedeploymenttool_=!"

    for /f "tokens=1,2 delims=-" %%A in ("!VER!") do (
        if %%A GTR !BEST_A! (
            set "BEST_A=%%A"
            set "BEST_B=%%B"
            set "ODT_EXE=%%F"
        ) else if %%A EQU !BEST_A! (
            if %%B GTR !BEST_B! (
                set "BEST_B=%%B"
                set "ODT_EXE=%%F"
            )
        )
    )
)

if not defined ODT_EXE (
    echo No officedeploymenttool_*-*.exe file found in files\
    goto :error
)

endlocal & set "ODT_EXE=%ODT_EXE%"
:--------------------------------------

echo Extracting setup...
"%ODT_EXE%" /extract:%temp%\office-install\ || goto :error
echo Copying the configuration file...
xcopy files\Configuration.xml %temp%\office-install\ || goto :error
cd %temp%\office-install\ || goto :error
echo Initializing the installation...
setup.exe /configure "Configuration.xml" || goto :error
echo Deleting installation files...
del /q %temp%\office-install\ || goto :error
echo Don't forget to activate your product!
echo Closing the program... 
timeout /t 3
goto :EOF

:error
echo Error #%errorlevel%
timeout /t 3
exit /b %errorlevel%