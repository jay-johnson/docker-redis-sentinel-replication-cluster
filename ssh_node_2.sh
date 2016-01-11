#!/bin/bash

nodename="redisnode2"

echo "SSHing into $nodename"

docker exec -t -i $nodename /bin/bash

