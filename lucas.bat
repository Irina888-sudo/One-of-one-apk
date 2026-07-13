@echo off
setlocal enabledelayedexpansion

:: ==============================================================================
:: CONFIGURATION DES CHEMINS
:: ==============================================================================
set "TOMCAT_DIR=C:\xampp\tomcat"
set "JAVA_17_DIR=C:\Program Files\Zulu\zulu-17"

:: Ajouter Java 17 au PATH pour cette session
set "PATH=%JAVA_17_DIR%\bin;%PATH%"

:: ==============================================================================

echo Utilisation de Java depuis : %JAVA_17_DIR%
echo Version de Java :
"%JAVA_17_DIR%\bin\java" -version
echo.

:: Vérifier que javac existe
if not exist "%JAVA_17_DIR%\bin\javac.exe" (
    echo [ERREUR] javac.exe non trouve dans %JAVA_17_DIR%\bin\
    echo Veuillez verifier le chemin d'installation de Java 17.
    pause
    exit /b 1
)

echo [1/4] Compilation des fichiers Java...
if not exist "WebContent\WEB-INF\classes" (
    mkdir "WebContent\WEB-INF\classes"
)

(for /f "delims=" %%i in ('dir /s /b src\*.java') do (
    set "filePath=%%i"
    set "filePath=!filePath:\=/!"
    echo "!filePath!"
)) > sources.txt

:: Compilation avec Java 17
"%JAVA_17_DIR%\bin\javac" --release 17 -cp ".;WebContent\WEB-INF\lib\*" -d WebContent\WEB-INF\classes @sources.txt
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
if exist "One-of-one-apk.war" del /f /q "One-of-one-apk.war"

cd WebContent
"%JAVA_17_DIR%\bin\jar" -cvf ..\One-of-one-apk.war .
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