#!/bin/bash
cd /root
source ~/.bash_profile*

# color
showGreen()
{
  echo -n -e "\033[32m$1 $2 $3 $4\033[0m"
}

# check
nodes=$(kubectl get nodes|grep NotReady|awk '{print $1}')
if [ "$nodes" = "" ];then
  (showGreen $(date '+%F %T') && echo -e "\tAll nodes are Ready. Exit.") >> drp.log
  exit 0
else
  for node in $nodes
  do
    node_drain_process=$(ps -ef|grep "kubectl drain $node"|grep -v grep|wc -l)
    if [ "$node_drain_process" -ge 1 ];then
        exit 0
    else
        (showGreen $(date '+%F %T') && echo -e "\t$node is NotReady ... Wait 10s") >> drp.log
        kubectl get nodes >> drp.log
        sleep 10s
  done
fi

# 10s
nodes=$(kubectl get nodes|grep NotReady|awk '{print $1}')
if [ "$nodes" = "" ];then
  (showGreen $(date '+%F %T') && echo -e "\tAll nodes are Ready. Exit.") >> drp.log
  exit 0
else
  for node in $nodes 
  do
    (showGreen $(date '+%F %T') && echo -e "\t$node will be cordon ...") >> drp.log 
    kubectl cordon $node >> drp.log
    kubectl get nodes >> drp.log
    (showGreen $(date '+%F %T') && echo -e "\tPods on $node will be drained ... ") >> drp.log
    kubectl drain $node --delete-local-data --force --ignore-daemonsets >> drp.log 
  done
fi
