
@echo off
setlocal enabledelayedexpansion

:: ==============================================================================
:: CONFIGURATION DES CHEMINS - PC FREDERIC
:: ==============================================================================
set "TOMCAT_DIR=C:\tomcat 10"

:: Definir JAVA_HOME (si non defini)
if "%JAVA_HOME%"=="" (
    set "JAVA_HOME=C:\Program Files\Java\jdk-21.0.11"
)
:: Ajouter le JDK au PATH pour cette session
set "PATH=%JAVA_HOME%\bin;%PATH%"

echo JAVA_HOME: %JAVA_HOME%
echo Java version:
"%JAVA_HOME%\bin\java" -version

:: ==============================================================================

echo [1/4] Compilation des fichiers Java...
if not exist "WebContent\WEB-INF\classes" (
    mkdir "WebContent\WEB-INF\classes"
)

:: Generer la liste de tous les fichiers .java recursivement
(for /f "delims=" %%i in ('dir /s /b src\*.java') do (
    set "filePath=%%i"
    set "filePath=!filePath:\=/!"
    echo "!filePath!"
)) >sources.txt

:: Compilation (cible Java 17 pour rester compatible avec Tomcat 8.5.x)
javac --release 17 -cp ".;WebContent\WEB-INF\lib\*" -d WebContent\WEB-INF\classes @sources.txt
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
:: Supprimer l'ancien WAR local pour eviter une copie erronee
if exist "One-of-one-apk.war" del /f /q "One-of-one-apk.war"

cd WebContent
set "JAR_CMD=%JAVA_HOME%\bin\jar.exe"
"%JAR_CMD%" -cvf ..\One-of-one-apk.war .
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
    echo [ATTENTION] Le dossier webapps de Tomcat n'a pas ete trouve.
    echo Le fichier WAR a ete genere localement mais n'a pas ete copie.
)

echo.
echo Processus termine avec succes.
pause
