:: Script par MANSUY Léo ::
:: Si modification du script, se rappeler d'encoder en ISO 8859-15 ::

@echo off
chcp 1252 >nul
setlocal
title Réinstallation propre de Microsoft.UI.Xaml 2.7.3

:: Variables
set "PACKAGE_NAME=Microsoft.UI.Xaml.2.7"
set "PACKAGE_FOLDER=%~dp0microsoft.ui.xaml.2.7.3\tools\AppX\x64\Release"
set "PACKAGE_APPX=%PACKAGE_FOLDER%\Microsoft.UI.Xaml.2.7.appx"
set "LOG_FILE=%~dp0ReinstallWinUI.log"

:: Nettoyer le fichier log au départ
> "%LOG_FILE%" echo [%date% %time%] [INFO] Début du script

:: Vérifier les droits admin
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Write-Host '[ERREUR] Droits administrateur absents. Relancement en mode administrateur...' -ForegroundColor Red"
    echo [%date% %time%] [ERREUR] Droits administrateur absents >> "%LOG_FILE%"
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
) else (
    echo [%date% %time%] [SUCCÈS] Droits administrateur validés >> "%LOG_FILE%"
)

:: Vérifier la présence du fichier .appx
if not exist "%PACKAGE_APPX%" (
    powershell -Command "Write-Host '[ERREUR] Fichier .appx introuvable : %PACKAGE_APPX%' -ForegroundColor Red"
    echo [%date% %time%] [ERREUR] Fichier .appx introuvable : %PACKAGE_APPX% >> "%LOG_FILE%"
    goto :wait_and_exit
) else (
    echo [%date% %time%] [SUCCÈS] Fichier .appx trouvé >> "%LOG_FILE%"
)

:: Vérifier si Microsoft.UI.Xaml.2.7 est déjà installé
powershell -Command "Get-AppxPackage -Name '%PACKAGE_NAME%'" >nul 2>&1
if %errorlevel% equ 0 (
    echo [INFO] %PACKAGE_NAME% est déjà installé. Suppression...
    echo [INFO] %PACKAGE_NAME% est déjà installé. Suppression... >> "%LOG_FILE%" 2>&1
    powershell -Command "Get-AppxPackage -Name '%PACKAGE_NAME%' | ForEach-Object { Remove-AppxPackage -Package $_.PackageFullName }" >> "%LOG_FILE%" 2>&1
    timeout /t 3 >nul
    echo [%date% %time%] [SUCCÈS] Package %PACKAGE_NAME% supprimé >> "%LOG_FILE%"
) else (
    echo [INFO] %PACKAGE_NAME% n'est pas déjà installé. >> "%LOG_FILE%" 2>&1
    echo [%date% %time%] [INFO] Package %PACKAGE_NAME% non trouvé (pas installé) >> "%LOG_FILE%"
)

:: Installer le package
echo [INFO] Installation de %PACKAGE_NAME% depuis %PACKAGE_APPX%...
echo [%date% %time%] [INFO] Début installation du package %PACKAGE_NAME% >> "%LOG_FILE%"
powershell -Command "Add-AppxPackage -Path '%PACKAGE_APPX%'" >> "%LOG_FILE%" 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Write-Host '[ERREUR] Échec de l''installation de %PACKAGE_NAME%. Voir log.' -ForegroundColor Red"
    echo [%date% %time%] [ERREUR] Échec de l'installation de %PACKAGE_NAME%. >> "%LOG_FILE%"
    goto :wait_and_exit
) else (
    echo [%date% %time%] [SUCCÈS] Installation de %PACKAGE_NAME% terminée >> "%LOG_FILE%"
)

:: Vérification post-installation
powershell -Command "Get-AppxPackage -Name '%PACKAGE_NAME%'" >> "%LOG_FILE%" 2>&1
if %errorlevel% equ 0 (
    powershell -Command "Write-Host '[SUCCÈS] Installation du package terminée. Veuillez lancer le portail entreprise pour vérification.' -ForegroundColor Green"
    echo [%date% %time%] [SUCCÈS] Vérification finale : %PACKAGE_NAME% installé avec succès >> "%LOG_FILE%"
) else (
    powershell -Command "Write-Host '[ERREUR] %PACKAGE_NAME% ne s''est pas réinstallé après la tentative de réinstallation ! Voir log.' -ForegroundColor Red"
    echo [%date% %time%] [ERREUR] %PACKAGE_NAME% absent après réinstallation >> "%LOG_FILE%"
)

echo [%date% %time%] [INFO] Fin du script >> "%LOG_FILE%"

:wait_and_exit
echo.
echo Appuyez sur une touche pour quitter...
pause >nul

:end
endlocal
exit /b
