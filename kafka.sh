#!/usr/bin/env bash

export __kafka=/opt/kafka/bin
export KAFKA_BROKERS="kafka:9092"

kafkaversion() {
    $__kafka/kafka-topics* --version
}

kafkals() {
    if [[ "$#" -eq 0 ]]; then
        # some installs have kafka-topics, some have kafka-topics.sh. Just use * to get whichever you have
        $__kafka/kafka-topics* --list --bootstrap-server "$KAFKA_BROKERS"
    else
        $__kafka/kafka-topics* --list --bootstrap-server "$KAFKA_BROKERS" --topic "$1"
    fi
}
kafkadescribe() {  # View configuration details about the current topic.
    $__kafka/kafka-topics*  --bootstrap-server "$KAFKA_BROKERS" --describe --topic "$1"
    # $__kafka/kafka-run-class* kafka.admin.ConsumerGroupCommand --bootstrap-server "$KAFKA_BROKERS" --list --all-groups
}
kafkagroup() {  # $1: consumer group (optional). $2: topic (optional)
     # View details about a consumer group
    if [[ "$#" -eq 0 ]]; then
      echo "Listing all consumer groups:"
      $__kafka/kafka-consumer-groups* --bootstrap-server "$KAFKA_BROKERS" --all-groups --list
    elif [[ "$#" -eq 1 ]]; then
      $__kafka/kafka-consumer-groups* --bootstrap-server "$KAFKA_BROKERS" --group "$1" --describe
    else
      if [[ $1 =~ ^-+t ]]; then
        echo "listing consumer groups for $2"
        echo "takes 5ever"
        for i in $($__kafka/kafka-consumer-groups* --bootstrap-server "$KAFKA_BROKERS" --all-groups --list); do
          $__kafka/kafka-consumer-groups* --bootstrap-server "$KAFKA_BROKERS" --describe --group $i | grep mytopic
        done
      fi
      $__kafka/kafka-consumer-groups* --bootstrap-server "$KAFKA_BROKERS" --group "$1" --describe | grep -e "$2" -e "GROUP"
    fi
}
kafkacount() {  # view number of messages in current topic, by partition
    echo "topic:partition:offset"
    local output="$($__kafka/kafka-run-class* kafka.tools.GetOffsetShell --broker-list "$KAFKA_BROKERS" --topic "$1")"
    echo "$output"
    printf "total: "
    echo "$output" | awk -F':' 'BEGIN{sum=0;}{sum+=$NF}END{print sum}' | hrnum
}
kafkabytes() {
  $__kafka/kafka-log-dirs* --bootstrap-server "$KAFKA_BROKERS" --describe --topic-list "$1" \
    | rg '^\{' | jq '[ ..|.size? | numbers ] | add' | hrbytes
}

kafkarm() { #this uses regex, not glob (e.g., drop.* not drop*)
    $__kafka/kafka-topics* --bootstrap-server "$KAFKA_BROKERS" --delete --topic "$1"
}
kafkaread() { #this uses regex, not glob (e.g., drop.* not drop*)
    # Kafka does NOT order these messages. It pulls from all X partitions and spits them out at you however it feels like.
    # If you want them in order, you need to make sure you give them to kafka with something sortable.
    # Chunks can be big, so if you try to grab a small snippet, you might only be grabbing from one partition.
    if [[ $# == 2 ]]; then
      local args="--partition $2 --offset earliest"
    else
      # doesn't work why?
      # local args="--group kafkaread --from-beginning"
      local args="--from-beginning"
    fi
    $__kafka/kafka-console-consumer* --bootstrap-server "$KAFKA_BROKERS" --topic "$1" --timeout-ms 50000 $args
}

kafkamk() {  # don't use this anywhere but your personal box.
    if [[ "$#" -eq 0 ]]; then
      echo "Provide a topic name to create"
      return 1
    fi
    $__kafka/kafka-topics* --create --bootstrap-server "$KAFKA_BROKERS" --replication-factor 1 --partitions 1 --topic "$1"
}

kafkawrite() {
    if [[ ! "$#" -eq 2 ]]; then
      echo "takes 2 arguments. kafkawrite <topic-name> <message>"
      return 1
    fi
    $__kafka/kafka-console-producer* --bootstrap-server "$KAFKA_BROKERS" --topic "$1" <<< "$2"
}

kafkawritefile() {
    if [[ ! "$#" -eq 2 ]]; then
      echo "takes 2 arguments. kafkawrite <topic-name> <file>"
      return 1
    fi
    cat "$2" | $__kafka/kafka-console-producer* --bootstrap-server "$KAFKA_BROKERS" --topic "$1"
}

kafkareadkeys() {
  $__kafka/kafka-console-consumer* --bootstrap-server "$KAFKA_BROKERS" --timeout-ms 5000 --property print.key=true --property key.separator=" | " --from-beginning --topic "$1"
}

export -f kafkaversion kafkals kafkadescribe kafkagroup kafkacount kafkabytes kafkarm kafkaread kafkamk kafkawrite kafkawritefile kafkareadkeys

