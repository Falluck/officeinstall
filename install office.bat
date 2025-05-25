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
:--------------------------------------

echo Extraction du setup...
files\officedeploymenttool_18730-20142.exe /extract:%temp%/office-install/ || goto :error
echo Copie du fichier de configuration...
xcopy files\ODTConfig.xml %temp%\office-install\ || goto :error
cd %temp%\office-install\ || goto :error
echo Initialisation de l'installation...
setup.exe /configure "ODTConfig.xml" || goto :error
echo Suppression des fichiers d'installations...
del /q %temp%\office-install\
echo N'oubliez pas d'activer votre licence Office
echo Fermeture du programme...
timeout /t 3
goto :EOF

:error
echo Erreur #%errorlevel%
exit /b %errorlevel%
