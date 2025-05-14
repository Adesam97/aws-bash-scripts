#!/bin/bash

set -e

while true; do
    read -p "What is your service log group name? " LOG_GROUP

    if ! aws logs describe-log-groups --log-group-name-prefix "$LOG_GROUP" --query "logGroups[?logGroupName=='$LOG_GROUP']" --output text | grep -q "$LOG_GROUP"; then
        echo "❌ Log group '$LOG_GROUP' does not exist."
        read -p "will you like to retry?(yes/no): " CHOICE
        if [ "$CHOICE" == "yes" ]; then
            continue
        else
            echo "Exiting script...!"
            exit 1
        fi
    else
       break
    fi
done

read -rp "How many log lines do you want to fetch? [default: 100] " LIMIT
LIMIT=${LIMIT:-100}

echo ""
echo "Fetching latest log stream from group: $LOG_GROUP..."

LOG_STREAM=$(aws logs describe-log-streams \
  --log-group-name "$LOG_GROUP" \
  --order-by "LastEventTime" \
  --descending \
  --limit 1 \
  --query "logStreams[0].logStreamName" \
  --output text)

if [ "$LOG_STREAM" == "None" ]; then
  echo "❌ No log streams found in group: $LOG_GROUP"
  exit 1
fi

echo "✅ Found stream: $LOG_STREAM"
OUTPUT_FILE="logs-${LOG_GROUP//\//_}-$(date +%Y%m%d-%H%M%S).txt"

aws logs get-log-events \
  --log-group-name "$LOG_GROUP" \
  --log-stream-name "$LOG_STREAM" \
  --limit "$LIMIT" \
  --output table > "$OUTPUT_FILE" \
  --query 'events[*].[timestamp, message]' 

echo "latest logs have been downloaded! Logs saved to: $OUTPUT_FILE"