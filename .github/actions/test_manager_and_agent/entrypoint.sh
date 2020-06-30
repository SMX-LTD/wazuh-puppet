#! /usr/bin/env bash
set -e

echo `systemctl status`
echo `ls -lah`
echo `git status`
echo `git branch`


cd kitchen

mkdir -p modules/wazuh

cd .. && cp -r `ls -A | grep -v "kitchen"` kitchen/modules/wazuh/

cd kitchen

echo "Installing dependencies"
bundle install

echo "Kitchen is creating the new instances"
bundle exec kitchen create

echo "Getting Wazuh managers IPs to the agents"
manager_ip="docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' manager"

echo "getting a copy of ./manifests/site.pp.template"
cp ./manifests/site.pp.template ./manifests/site.pp

echo "wazuh-manager IP"
echo $manager_ip

echo "Assigning Wazuh managers IPs to the corresponding agents."
sed -i 's/manager_ip/'${manager_ip}'/g' ./manifests/site.pp


echo "Kitchen is converging ..."
bundle exec kitchen converge

echo "Kitchen is testing ..."
bundle exec kitchen verify

echo "Kitchen is destroying"
bundle exec kitchen destroy
