#!/bin/bash

echo "Stop Service"
echo "============================================"
sudo systemctl stop dashboard
sudo systemctl stop opendaylight

echo "Remove Service"
echo "============================================"
sudo rm -rf /etc/systemd/system/dashboard.service
sudo rm -rf /etc/systemd/system/opendaylight.service

echo "Remove Data"
echo "============================================"
sudo rm -rf /opt/PureFlow