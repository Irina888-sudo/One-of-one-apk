#!/bin/bash

# ===========================
# Configuration
# ===========================
APP_NAME="One-of-one-apk"

SRC_DIR="src"
WEB_DIR="WebContent"
BUILD_CLASSES="$WEB_DIR/WEB-INF/classes"

# Ton chemin Tomcat actuel
TOMCAT_WEBAPPS="/Users/airs/Documents/tomcat/webapps"
# Extraction automatique du dossier racine de Tomcat pour inclure les libs
TOMCAT_HOME=$(dirname "$TOMCAT_WEBAPPS")

# ===========================
# Nettoyage
# ===========================
echo "=== Nettoyage ==="

rm -rf "$BUILD_CLASSES"
mkdir -p "$BUILD_CLASSES"

# ===========================
# Compilation
# ===========================
echo "=== Compilation des fichiers Java ==="

find "$SRC_DIR" -name "*.java" > sources.txt

# Correction du Classpath pour macOS (separateur ':') avec servlet-api.jar de Tomcat
javac \
-cp "$TOMCAT_HOME/lib/servlet-api.jar:$WEB_DIR/WEB-INF/lib/*" \
-d "$BUILD_CLASSES" \
@sources.txt

if [ $? -ne 0 ]; then
    echo ""
    echo "❌ Erreur de compilation."
    rm -f sources.txt
    exit 1
fi

rm -f sources.txt

# ===========================
# Creation du WAR
# ===========================
echo "=== Creation du fichier WAR ==="

cd "$WEB_DIR" || exit

jar -cvf "../$APP_NAME.war" .

cd ..

# ===========================
# Deploiement dans Tomcat
# ===========================
echo "=== Deploiement ==="

rm -f "$TOMCAT_WEBAPPS/$APP_NAME.war"
rm -rf "$TOMCAT_WEBAPPS/$APP_NAME"

cp "$APP_NAME.war" "$TOMCAT_WEBAPPS/"

echo ""
echo "✅ Deploiement termine !"
echo "Le fichier $APP_NAME.war a ete copie dans :"
echo "$TOMCAT_WEBAPPS"
echo ""
echo "Redemarre Tomcat si necessaire."