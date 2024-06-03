#!/bin/bash

# Set the directory where log files are located
LOG_DIR="/path/to/log/directory"

# Set the file extension of log files to be cleaned up
LOG_EXTENSION=".log"

# Define the number of weeks to retain logs
RETENTION_PERIOD_WEEKS=4

# Get the current date
CURRENT_DATE=$(date +"%Y-%m-%d")

# Calculate the date of last Friday
LAST_FRIDAY=$(date -d "last Friday" +"%Y-%m-%d")

# Check if today is Friday
if [ $(date +"%A") == "Friday" ]; then
    # Loop through log files in the log directory
    for LOG_FILE in "$LOG_DIR"/*"$LOG_EXTENSION"; do
        # Extract the date part from the log file name
        LOG_DATE=$(basename "$LOG_FILE" "$LOG_EXTENSION")

        # Check if the log file date is older than the retention period
        if [[ "$LOG_DATE" < "$(date -d "$LAST_FRIDAY - $RETENTION_PERIOD_WEEKS weeks" +"%Y-%m-%d")" ]]; then
            echo "Removing old log file: $LOG_FILE"
            rm "$LOG_FILE"
        fi
    done
fi
