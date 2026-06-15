javac -encoding UTF-8 -cp ".;WebContent/WEB-INF/lib/*" -d WebContent/WEB-INF/classes src\model\*.java src\dao\*.java src\util\*.java
cd WebContent
jar -cvf ..\One-of-one-apk.war .
cd ..

rmdir /s /q C:\xampp\tomcat\webapps\One-of-one-apk
rmdir /s /q C:\xampp\tomcat\work\Catalina\localhost\One-of-one-apk

copy One-of-one-apk.war C:\xampp\tomcat\webapps\