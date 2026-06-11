#
javac -cp .:WebContent/WEB-INF/lib/* -d WebContent/WEB-INF/classes src/**/*.java

cd WebContent
jar -cvf ../One-of-one-apk.war .
cd ..

sudo rm -rf /opt/tomcat/webapps/One-of-one-apk*
sudo rm -rf /opt/tomcat/work/Catalina/localhost/One-of-one-apk*

sudo cp One-of-one-apk.war /opt/tomcat/webapps/

sudo chown -R tomcat:tomcat /opt/tomcat/webapps/One-of-one-apk.war