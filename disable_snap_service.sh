#! /bin/bash
snap_services=$(systemctl list-unit-files | grep snap|grep enabled|cut -d ' ' -f 1)
for snap_service in $snap_services; do
cmd="sudo systemctl enable $snap_service"
echo $cmd
$cmd
done
