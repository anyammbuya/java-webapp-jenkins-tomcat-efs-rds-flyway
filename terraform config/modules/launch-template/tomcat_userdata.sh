#!/bin/bash
set -e

# Update system and install Java
dnf update -y
dnf install -y java-21-amazon-corretto wget

# Install Tomcat
cd /opt
wget https://archive.apache.org/dist/tomcat/tomcat-10/v10.1.47/bin/apache-tomcat-10.1.47.tar.gz
tar -zvxf apache-tomcat-10.1.47.tar.gz
mv apache-tomcat-10.1.47 tomcat

# --- NEW: Add RemoteIpValve to server.xml for ALB proxy awareness ---
SERVER_XML=/opt/tomcat/conf/server.xml

# Use sed to find the closing </Host> tag and insert the Valve before it
# Note: You may need to adjust the internalProxies regex if your VPC uses different private IP ranges
sed -i '/<\/Host>/i \
    <Valve className="org.apache.catalina.valves.RemoteIpValve" \
           internalProxies="10\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}|192\\.168\\.\\d{1,3}\\.\\d{1,3}|169\\.254\\.\\d{1,3}\\.\\d{1,3}" \
           remoteIpHeader="x-forwarded-for" \
           protocolHeader="x-forwarded-proto" \
           hostHeader="x-forwarded-host" \
    />' $SERVER_XML

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


# Create the tomcat user

TOMCAT_ID=1002

if ! id -u tomcat >/dev/null 2>&1; then
    echo "Creating tomcat group and user with ID $TOMCAT_ID..."
    groupadd -g $TOMCAT_ID tomcat
    useradd -u $TOMCAT_ID -r -g tomcat -d /opt/tomcat -s /sbin/nologin tomcat
fi


# Mount the EFS

# Install the EFS helper
dnf install -y amazon-efs-utils

# Create the directory
mkdir -p /opt/tomcat/webapps_backup

mv /opt/tomcat/webapps/* /opt/tomcat/webapps_backup

# Mount using the Access Point ID instead of just the EFS ID
mount -t efs -o tls,accesspoint=${efs_accesspt_id} ${efs_id}:/ /opt/tomcat/webapps
#mount -t efs -o tls,accesspoint=fsap-051f96a2a529d2936 fs-04560ec69bfac2138:/ /opt/tomcat/webapps

# Ensure it mounts automatically on reboot
echo "${efs_id}:/ /opt/tomcat/webapps efs _netdev,tls,accesspoint=${efs_accesspt_id} 0 0" >> /etc/fstab

cp -r /opt/tomcat/webapps_backup/* /opt/tomcat/webapps/
rm -rf /opt/tomcat/webapps_backup
chown -R tomcat:tomcat /opt/tomcat/webapps


# Start Tomcat
/opt/tomcat/bin/startup.sh

# Check logs when after building the war file or when it is executing
# cat /opt/tomcat/logs/catalina.out
# clear the logs
# true > /opt/tomcat/logs/catalina.out     
# Install mysql client and login to the RDS
# dnf install mariadb105 -y
# mysql -h zeus-db.cxsee6smsxz1.us-west-2.rds.amazonaws.com -P 3306 -u admin -p
