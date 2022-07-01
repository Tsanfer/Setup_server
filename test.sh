#!/bin/bash

    docker_list=("code-server" "nginx" "pure-ftpd")
    for i in ${!docker_list[@]}; do   
      echo "$i. ${docker_list[$i]}"
    done 
