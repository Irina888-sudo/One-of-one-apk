javac -cp .:/WebContent/WEB-INF/lib/ojdbc11.jar -d WEB-INF/classes src/**/*.java
jar -cvf Gold.war .
sudo rm -rf /opt/tomcat/webapps/Gold*
sudo cp Gold.war /opt/tomcat/webapps/
