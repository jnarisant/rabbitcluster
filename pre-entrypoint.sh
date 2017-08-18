#!/bin/bash

(
  if [[ "$1" == "rabbitmq-server" ]]; then
    while [[ -z "$(ps -A | grep rabbitmq-server)" ]]; do
      sleep 10
    done
    
    if [[ -n "$RABBITMQ_SSL_KEY_FILE" && -n "$RABBITMQ_SSL_CA_FILE" ]]; then
       export RABBITMQ_CTL_ERL_ARGS="-proto_dist inet_tls"
    fi
    
    sleep 20
    echo "I think it's up!!!"
    cp $HOME/.erlang.cookie /var/lib/rabbitmq
    oldifs="$IFS"
    IFS=$'\n'
    policies=$(env | grep "RABBITMQ_POLICY" | sed 's/[^=]*=//')
    for policy in $policies ; do 
      ( 
        IFS="$oldifs"
        cmd="rabbitmqctl set_policy $policy"
        echo "Running $cmd..."
        $cmd
      )
    done
  fi
) &

./docker-entrypoint.sh $@