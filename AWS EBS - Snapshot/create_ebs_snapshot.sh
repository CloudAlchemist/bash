#!/bin/bash

# Set your AWS region
AWS_REGION="your-region"

# Set the EBS volume ID
VOLUME_ID="your-ebs-volume-id"

# Set the number of snapshots to keep
SNAPSHOTS_TO_KEEP=5

# Create a snapshot of the EBS volume
echo "Creating snapshot of EBS volume $VOLUME_ID..."
snapshot_id=$(aws ec2 create-snapshot --region $AWS_REGION --volume-id $VOLUME_ID --description "Snapshot created $(date +'%Y-%m-%d %H:%M:%S')" --query 'SnapshotId' --output text)

if [ $? -eq 0 ]; then
    echo "Snapshot $snapshot_id created successfully."
else
    echo "Error creating snapshot. Please check your configuration and try again."
    exit 1
fi

# Delete older snapshots
echo "Deleting older snapshots..."
snapshots=$(aws ec2 describe-snapshots --region $AWS_REGION --filters Name=volume-id,Values=$VOLUME_ID --query 'Snapshots[*].{ID:SnapshotId,StartTime:StartTime}' --output text | sort -k 2 | awk '{print $1}')
num_snapshots=$(echo "$snapshots" | wc -l)

if [ $num_snapshots -gt $SNAPSHOTS_TO_KEEP ]; then
    snapshots_to_delete=$(echo "$snapshots" | head -n -$SNAPSHOTS_TO_KEEP)
    echo "Deleting $num_snapshots - $SNAPSHOTS_TO_KEEP = $(echo "$snapshots_to_delete" | wc -l) snapshots..."
    for snapshot_id in $snapshots_to_delete; do
        aws ec2 delete-snapshot --region $AWS_REGION --snapshot-id $snapshot_id
    done
    echo "Older snapshots deleted successfully."
else
    echo "No older snapshots to delete."
fi
