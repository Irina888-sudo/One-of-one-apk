@echo off
setlocal enabledelayedexpansion

:: ==============================================================================
:: CONFIGURATION DES CHEMINS - MODIFIEZ CES CHEMINS SELON VOTRE CONFIGURATION
:: ==============================================================================
set "TOMCAT_DIR=C:\tomcat 10"
:: ==============================================================================

echo [1/4] Compilation des fichiers Java...
if not exist "WebContent\WEB-INF\classes" (
    mkdir "WebContent\WEB-INF\classes"
)

:: Generer la liste de tous les fichiers .java recursivement
dir /s /b src\*.java > sources.txt

:: Compiler en utilisant la liste des fichiers et le classpath Windows (avec le separateur ';')
javac -cp ".;WebContent\WEB-INF\lib\*" -d WebContent\WEB-INF\classes @sources.txt
if %errorlevel% neq 0 (
    echo [ERREUR] La compilation a echoue !
    del sources.txt
    pause
    exit /b %errorlevel%
)
del sources.txt
echo Compilation reussie.

echo.
echo [2/4] Creation du fichier WAR...
cd WebContent
jar -cvf ..\One-of-one-apk.war .
if %errorlevel% neq 0 (
    echo [ERREUR] La creation du fichier WAR a echoue !
    cd ..
    pause
    exit /b %errorlevel%
)
cd ..
echo Fichier WAR cree avec succes.

echo.
echo [3/4] Nettoyage du dossier Tomcat...
:: Suppression de l'ancien fichier WAR et du dossier deploye s'ils existent
if exist "%TOMCAT_DIR%\webapps\One-of-one-apk.war" (
    del /f /q "%TOMCAT_DIR%\webapps\One-of-one-apk.war"
)
if exist "%TOMCAT_DIR%\webapps\One-of-one-apk" (
    rmdir /s /q "%TOMCAT_DIR%\webapps\One-of-one-apk"
)
if exist "%TOMCAT_DIR%\work\Catalina\localhost\One-of-one-apk" (
    rmdir /s /q "%TOMCAT_DIR%\work\Catalina\localhost\One-of-one-apk"
)
echo Nettoyage effectue.

echo.
echo [4/4] Deploiement du fichier WAR dans Tomcat...
if exist "%TOMCAT_DIR%\webapps" (
    copy One-of-one-apk.war "%TOMCAT_DIR%\webapps\"
    if %errorlevel% neq 0 (
        echo [ERREUR] Le deploiement vers Tomcat a echoue. Verifiez les permissions d'ecriture.
        pause
        exit /b %errorlevel%
    )
    echo Deploiement reussi !
) else (
    echo [ATTENTION] Le dossier webapps de Tomcat n'a pas ete trouve a l'emplacement :
    echo "%TOMCAT_DIR%\webapps"
    echo Le fichier One-of-one-apk.war a ete genere localement mais n'a pas ete copie.
)

echo.
echo Processus termine avec succes.
pause
