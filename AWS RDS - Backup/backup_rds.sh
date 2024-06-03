#!/bin/bash

# Set your AWS region
AWS_REGION="your-region"

# Set the RDS instance identifier
RDS_INSTANCE_ID="your-rds-instance-id"

# Set the S3 bucket name for storing backups
S3_BUCKET="your-s3-bucket-name"

# Set the backup filename prefix
BACKUP_PREFIX="rds-backup"

# Set the number of backups to keep
BACKUPS_TO_KEEP=5

# Perform database backup
echo "Performing backup of RDS instance $RDS_INSTANCE_ID..."
backup_filename="$BACKUP_PREFIX-$(date +"%Y-%m-%d-%H-%M-%S").sql"
mysqldump -h $RDS_INSTANCE_ID -u username -p'password' dbname > $backup_filename

if [ $? -eq 0 ]; then
    echo "Backup completed successfully: $backup_filename"
else
    echo "Error performing backup. Please check your configuration and try again."
    exit 1
fi

# Upload backup to S3
echo "Uploading backup to S3 bucket $S3_BUCKET..."
aws s3 cp $backup_filename s3://$S3_BUCKET/

if [ $? -eq 0 ]; then
    echo "Backup uploaded successfully to S3."
else
    echo "Error uploading backup to S3. Please check your configuration and try again."
    exit 1
fi

# Clean up local backup files
echo "Cleaning up local backup files..."
rm $backup_filename

# Delete older backups from S3
echo "Deleting older backups from S3..."
backup_list=$(aws s3 ls s3://$S3_BUCKET/ | awk '{print $4}' | grep "$BACKUP_PREFIX")

num_backups=$(echo "$backup_list" | wc -l)
if [ $num_backups -gt $BACKUPS_TO_KEEP ]; then
    num_backups_to_delete=$((num_backups - BACKUPS_TO_KEEP))
    backups_to_delete=$(echo "$backup_list" | head -n $num_backups_to_delete)

    for backup_name in $backups_to_delete; do
        aws s3 rm s3://$S3_BUCKET/$backup_name
    done

    echo "Older backups deleted successfully from S3."
else
    echo "No older backups to delete from S3."
fi

echo "Backup process completed successfully."
