#!/bin/bash
echo "Update the repository"
echo "============================================"
sudo apt-get -y update

echo "Install software-properties-common"
echo "============================================"
sudo apt-get install -y software-properties-common 

echo "Add Ansible Repository"
echo "============================================"
sudo apt-add-repository -y ppa:ansible/ansible

echo "Update the repository"
echo "============================================"
sudo apt-get -y update

echo "Install Ansible"
echo "============================================"
sudo apt-get install -y ansible crudini

echo "Configure ansible"
echo "============================================"
sudo crudini --set /etc/ansible/ansible.cfg defaults host_key_checking False

echo "Install requirement package"
echo "============================================"
sudo apt-get install -y wget curl nano unzip git python-minimal python-pip

echo "Clone Repository"
echo "============================================"
git clone https://github.com/zufardhiyaulhaq/PureFlow.git
sudo mv PureFlow/ /opt/

echo "Creating Daemon for Dashboard"
echo "============================================"
sudo sh -c 'cat << EOF > /etc/systemd/system/dashboard.service
[Unit]
Description=Dashboard Service

[Service]
User=root
Group=root
WorkingDirectory=/opt/PureFlow/dashboard/
ExecStart=/usr/bin/python /opt/PureFlow/dashboard/dashboard.py

[Install]
WantedBy=multi-user.target
EOF'

echo "fix locale python"
echo "============================================"
export LC_ALL=C
echo "export LC_ALL=C" >> ~/.bashrc
source ~/.bashrc

echo "Install python dashboard requirement"
echo "============================================"
sudo pip install -r /opt/PureFlow/dashboard/requirement.txt

echo "Running dashboard program"
echo "============================================"
sudo systemctl enable dashboard
sudo systemctl start dashboard

echo "Install Java JRE"
echo "============================================"
sudo apt-get install -y default-jre

echo "Download ONOS"
echo "============================================"
wget http://repo1.maven.org/maven2/org/onosproject/onos-releases/1.13.2/onos-1.13.2.zip

echo "Unzip ONOS"
echo "============================================"
sudo mv onos-1.13.2.zip /opt/
cd /opt/
sudo unzip onos-1.13.2.zip

echo "Configuring ONOS"
echo "============================================"
sudo mv onos-1.13.2 onos
cd onos
sudo sed -i '/ONOS_APPS=${ONOS_APPS:-}/c\ONOS_APPS=openflow' bin/onos-service

echo "Creating Daemon for ONOS"
echo "============================================"
sudo cp /opt/onos/init/onos.initd /etc/init.d/onos
sudo cp /opt/onos/init/onos.service /etc/systemd/system/

echo "Starting ONOS as backgroud"
echo "============================================"
export LC_ALL=C
sudo systemctl daemon-reload
sudo systemctl enable onos.service

sleep 10

sudo systemctl start onos.service

echo "Update the repository"
echo "============================================"
sudo apt-get -y update

echo "Install mysql"
echo "============================================"
sudo apt-get -y install mysql-server libmysqlclient-dev

echo "Bootstraping mysql database"
echo "============================================"
DATABASE="pureflow"
USERDB="pureflowadmin"
PASSWDDB="pureflowpassword"

echo "Please enter root user MySQL password!"
echo "============================================"
read rootpasswd

echo "Creating Databases"
echo "============================================"
mysql -uroot -p${rootpasswd} -e "CREATE DATABASE ${DATABASE};"
mysql -uroot -p${rootpasswd} -e "CREATE USER '${USERDB}'@'%' IDENTIFIED BY '${PASSWDDB}';"
mysql -uroot -p${rootpasswd} -e "GRANT ALL PRIVILEGES ON ${DATABASE} . * TO '${USERDB}'@'%';"
mysql -uroot -p${rootpasswd} -e "SHOW GRANTS FOR '${USERDB}'@'%';"
mysql -uroot -p${rootpasswd} -e "FLUSH PRIVILEGES;"

echo "Import Databases"
echo "============================================"
sudo mysql -u${USERDB} -p${PASSWDDB} ${DATABASE} < /opt/PureFlow/bootstrap/instalation/pureflow.sql


