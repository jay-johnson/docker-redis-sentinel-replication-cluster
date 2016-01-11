#!/bin/bash

nodename="redisnode3"

echo "SSHing into $nodename"

docker exec -t -i $nodename /bin/bash

