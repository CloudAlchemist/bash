#!/bin/bash

# Set your AWS region and instance ID
AWS_REGION="your-region"
INSTANCE_ID="your-instance-id"

# Start EC2 instance
start_instance() {
    echo "Starting EC2 instance..."
    aws ec2 start-instances --region $AWS_REGION --instance-ids $INSTANCE_ID
    aws ec2 wait instance-running --region $AWS_REGION --instance-ids $INSTANCE_ID
    echo "EC2 instance started successfully."
}

# Stop EC2 instance
stop_instance() {
    echo "Stopping EC2 instance..."
    aws ec2 stop-instances --region $AWS_REGION --instance-ids $INSTANCE_ID
    aws ec2 wait instance-stopped --region $AWS_REGION --instance-ids $INSTANCE_ID
    echo "EC2 instance stopped successfully."
}

# Check if argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 [start|stop]"
    exit 1
fi

# Start or stop instance based on provided argument
case "$1" in
    start)
        start_instance
        ;;
    stop)
        stop_instance
        ;;
    *)
        echo "Invalid option: $1. Please use 'start' or 'stop'."
        exit 1
        ;;
esac
