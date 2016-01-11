## A Distributed Redis + Sentinel Replication Cluster using Docker Swarm, Docker Compose, and Supervisor

### Overview

This repository will start a distributed 3-node replication cluster using Redis, Sentinel and Supervisor using Docker Swarm and Compose for high availability. There are 3 Redis instances listening on ports: 9000-9002. There can be only 1 master Redis node at a time and the other 2 nodes are set up for fault-tolerant replication with Sentinel and Supervisor. The goal of this replication cluster is to reduce message and data loss even when the master Redis node crashes. When the master node crashes Sentinel will host a leader election and another node will become the new master by winning the election. Supervisor runs in each container and will automatically attempt to restart any stopped Redis instance. Sentinel is paired up with each Redis server and listens on ports 19000-19002 (***Redis Server Port*** + 10000).

### How to Install

1. Make sure Swarm is installed 

  ```
  docker-redis-sentinel-replication-cluster $ sudo ./_install_docker_services.sh
  ```

1. Restart the local consul, docker daemon, swarm manager, and swarm join

  ```
  docker-redis-sentinel-replication-cluster $ sudo ./boot_local_docker_services.sh
  ``` 

1. Point to the Docker Swarm

  Please set the terminal environment to use the running Docker Swarm 
  
  ```
  $ export DOCKER_HOST=localhost:4000
  $ env | grep DOCKER
  DOCKER_HOST=localhost:4000
  $
  ```

1. Confirm the Docker Swarm Membership

  Running the swarm locally you should see only 1 node with something similar:

  ```
  $ docker info
  Containers: 0
  Images: 0
  Role: primary
  Strategy: spread
  Filters: health, port, dependency, affinity, constraint
  Nodes: 1
   localhost.localdomain: localhost:2375
    └ Containers: 0
    └ Reserved CPUs: 0 / 2
    └ Reserved Memory: 0 B / 4.053 GiB
    └ Labels: executiondriver=native-0.2, kernelversion=4.1.7-200.fc22.x86_64, operatingsystem=Fedora 22 (Twenty Two), storagedriver=devicemapper
  CPUs: 2
  Total Memory: 4.053 GiB
  Name: localhost.localdomain
  $
  ```

### Start the Redis Replication Cluster 

Assuming consul, docker daemon, swarm manager, and swarm join are running with something similar to:

```
$ ps auwwx | grep consul | grep -v grep
root     29447  0.4  0.4 34110388 19204 pts/4  Sl   19:39   0:14 consul agent -server -data-dir=/tmp/consul -bind=0.0.0.0 -bootstrap-expect 1
root     31650 12.9  1.2 1329604 51208 pts/4   Sl   20:00   3:42 /usr/local/bin/docker daemon -H localhost:2375 --cluster-advertise 0.0.0.0:2375 --cluster-store consul://localhost:8500/developmentswarm
root     31738  0.0  0.5 488084 20512 pts/1    Sl   20:02   0:01 /usr/local/bin/swarm manage -H tcp://localhost:4000 --advertise localhost:4000 consul://localhost:8500/developmentswarm
root     31749  0.0  0.3 128416 14304 pts/1    Sl   20:02   0:00 /usr/local/bin/swarm join --addr=localhost:2375 consul://localhost:8500/developmentswarm
$
```
 
1. Make sure no other Redis nodes are running

  ```
  $ docker ps -a
  CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
  $ 
  ```

1. Start the Redis Cluster

  ```
  docker-redis-sentinel-replication-cluster $ ./start_cluster.sh 
  Starting the Redis Replication Cluster on Docker Swarm
  Creating redisnode1
  Creating redisnode3
  Creating redisnode2
  Done
  docker-redis-sentinel-replication-cluster $
  ```

1. Confirm the Containers are running

  ```
  $ docker ps
  bbdd5e7bdeaf        jayjohnson/redis-sentinel-supervisor-clusterable   "/bin/sh -c '. /bin/s"   24 seconds ago      Up 23 seconds       127.0.0.1:9001->9001/tcp, 6379/tcp, 127.0.0.1:19001->19001/tcp   localhost.localdomain/redisnode2
  113642320e1b        jayjohnson/redis-sentinel-supervisor-clusterable   "/bin/sh -c '. /bin/s"   24 seconds ago      Up 23 seconds       127.0.0.1:9002->9002/tcp, 6379/tcp, 127.0.0.1:19002->19002/tcp   localhost.localdomain/redisnode3
  94f3a89efc19        jayjohnson/redis-sentinel-supervisor-clusterable   "/bin/sh -c '. /bin/s"   25 seconds ago      Up 24 seconds       127.0.0.1:9000->9000/tcp, 6379/tcp, 127.0.0.1:19000->19000/tcp   localhost.localdomain/redisnode1
  $
  ```

### Find the Redis Cluster Master Node using the Command Line Tool or Script


```
$ redis-cli -p 19000 sentinel get-master-addr-by-name redis-cluster
1) "10.0.0.2"
2) "9000"
$ 
```

```
$ ./get_cluster_master.sh 
1) "10.0.0.2"
2) "9000"
$
```

### Stop the Redis Cluster

```
$ ./stop_cluster.sh 
Stopping the Redis Replication Cluster on Docker Swarm
Stopping redisnode2 ... 
Stopping redisnode3 ... 
Stopping redisnode1 ... 
$
```

