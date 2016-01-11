#!/bin/bash

redis-cli -p 19000 sentinel get-master-addr-by-name redis-cluster
