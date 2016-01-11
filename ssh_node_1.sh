#!/bin/bash

nodename="redisnode1"

echo "SSHing into $nodename"

docker exec -t -i $nodename /bin/bash

