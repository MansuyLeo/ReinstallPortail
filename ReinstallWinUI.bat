:: Script par MANSUY L�o ::
:: Si modification du script, se rappeler d'encoder en ISO 8859-15 ::

@echo off
chcp 1252 >nul
setlocal
title R�installation propre de Microsoft.UI.Xaml 2.7.3

:: Variables
set "PACKAGE_NAME=Microsoft.UI.Xaml.2.7"
set "PACKAGE_FOLDER=%~dp0microsoft.ui.xaml.2.7.3\tools\AppX\x64\Release"
set "PACKAGE_APPX=%PACKAGE_FOLDER%\Microsoft.UI.Xaml.2.7.appx"
set "LOG_FILE=%~dp0ReinstallWinUI.log"

:: Nettoyer le fichier log au d�part
> "%LOG_FILE%" echo [%date% %time%] [INFO] D�but du script

:: V�rifier les droits admin
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Write-Host '[ERREUR] Droits administrateur absents. Relancement en mode administrateur...' -ForegroundColor Red"
    echo [%date% %time%] [ERREUR] Droits administrateur absents >> "%LOG_FILE%"
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
) else (
    echo [%date% %time%] [SUCC�S] Droits administrateur valid�s >> "%LOG_FILE%"
)

:: V�rifier la pr�sence du fichier .appx
if not exist "%PACKAGE_APPX%" (
    powershell -Command "Write-Host '[ERREUR] Fichier .appx introuvable : %PACKAGE_APPX%' -ForegroundColor Red"
    echo [%date% %time%] [ERREUR] Fichier .appx introuvable : %PACKAGE_APPX% >> "%LOG_FILE%"
    goto :wait_and_exit
) else (
    echo [%date% %time%] [SUCC�S] Fichier .appx trouv� >> "%LOG_FILE%"
)

:: V�rifier si Microsoft.UI.Xaml.2.7 est d�j� install�
powershell -Command "Get-AppxPackage -Name '%PACKAGE_NAME%'" >nul 2>&1
if %errorlevel% equ 0 (
    echo [INFO] %PACKAGE_NAME% est d�j� install�. Suppression...
    echo [INFO] %PACKAGE_NAME% est d�j� install�. Suppression... >> "%LOG_FILE%" 2>&1
    powershell -Command "Get-AppxPackage -Name '%PACKAGE_NAME%' | ForEach-Object { Remove-AppxPackage -Package $_.PackageFullName }" >> "%LOG_FILE%" 2>&1
    timeout /t 3 >nul
    echo [%date% %time%] [SUCC�S] Package %PACKAGE_NAME% supprim� >> "%LOG_FILE%"
) else (
    echo [INFO] %PACKAGE_NAME% n'est pas d�j� install�. >> "%LOG_FILE%" 2>&1
    echo [%date% %time%] [INFO] Package %PACKAGE_NAME% non trouv� (pas install�) >> "%LOG_FILE%"
)

:: Installer le package
echo [INFO] Installation de %PACKAGE_NAME% depuis %PACKAGE_APPX%...
echo [%date% %time%] [INFO] D�but installation du package %PACKAGE_NAME% >> "%LOG_FILE%"
powershell -Command "Add-AppxPackage -Path '%PACKAGE_APPX%'" >> "%LOG_FILE%" 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Write-Host '[ERREUR] �chec de l''installation de %PACKAGE_NAME%. Voir log.' -ForegroundColor Red"
    echo [%date% %time%] [ERREUR] �chec de l'installation de %PACKAGE_NAME%. >> "%LOG_FILE%"
    goto :wait_and_exit
) else (
    echo [%date% %time%] [SUCC�S] Installation de %PACKAGE_NAME% termin�e >> "%LOG_FILE%"
)

:: V�rification post-installation
powershell -Command "Get-AppxPackage -Name '%PACKAGE_NAME%'" >> "%LOG_FILE%" 2>&1
if %errorlevel% equ 0 (
    powershell -Command "Write-Host '[SUCC�S] Installation du package termin�e. Veuillez lancer le portail entreprise pour v�rification.' -ForegroundColor Green"
    echo [%date% %time%] [SUCC�S] V�rification finale : %PACKAGE_NAME% install� avec succ�s >> "%LOG_FILE%"
) else (
    powershell -Command "Write-Host '[ERREUR] %PACKAGE_NAME% ne s''est pas r�install� apr�s la tentative de r�installation ! Voir log.' -ForegroundColor Red"
    echo [%date% %time%] [ERREUR] %PACKAGE_NAME% absent apr�s r�installation >> "%LOG_FILE%"
)

echo [%date% %time%] [INFO] Fin du script >> "%LOG_FILE%"

:wait_and_exit
echo.
echo Appuyez sur une touche pour quitter...
pause >nul

:end
endlocal
exit /b
