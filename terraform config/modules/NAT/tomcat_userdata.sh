#!/bin/bash
set -e

# Update system and install Java
dnf update -y
dnf install -y java-21-amazon-corretto wget

# Install Tomcat
cd /opt
wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.46/bin/apache-tomcat-10.1.46.tar.gz
tar -zvxf apache-tomcat-10.1.46.tar.gz
mv apache-tomcat-10.1.46 tomcat

# Create symlinks for start/stop
ln -s /opt/tomcat/bin/startup.sh /usr/local/bin/tomcatup
ln -s /opt/tomcat/bin/shutdown.sh /usr/local/bin/tomcatdown

# Comment out RemoteAddrValve in context.xml files (allow Manager/Host Manager remote access)
for file in /opt/tomcat/webapps/docs/META-INF/context.xml \
            /opt/tomcat/webapps/host-manager/META-INF/context.xml \
            /opt/tomcat/webapps/manager/META-INF/context.xml
do
  if grep -q 'RemoteAddrValve' "$file"; then
    sed -i 's/<Valve className="org.apache.catalina.valves.RemoteAddrValve"/<!-- <Valve className="org.apache.catalina.valves.RemoteAddrValve"/' "$file"
    sed -i 's/\/>$/\/> -->/' "$file"
  fi
done

# Add users/roles to tomcat-users.xml
TOMCAT_USERS=/opt/tomcat/conf/tomcat-users.xml

# Remove closing </tomcat-users> first to append roles/users cleanly
sed -i '/<\/tomcat-users>/d' $TOMCAT_USERS

cat <<EOT >> $TOMCAT_USERS
<role rolename="manager-gui"/>
<role rolename="manager-script"/>
<role rolename="manager-jmx"/>
<role rolename="manager-status"/>
<user username="admin" password="admin" roles="manager-gui,manager-script,manager-jmx,manager-status"/>
<user username="deployer" password="deployer" roles="manager-script"/>
<user username="tomcat" password="s3cret" roles="manager-gui"/>
</tomcat-users>
EOT

# Start Tomcat
/opt/tomcat/bin/startup.sh
