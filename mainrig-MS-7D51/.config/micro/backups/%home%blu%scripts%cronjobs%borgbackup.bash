#!/usr/bin/bash
[ -f /home/blu/.secure_env ] && source /home/blu/.secure_env

# Common exclusions for borg
COMMON_EXCLUSIONS=(
    "--exclude-caches"
    "--exclude=/.snapshots/*"
    "--exclude=/dev/*"
    "--exclude=/home/blu/audio"
    "--exclude=/home/blu/manga"
    "--exclude=/home/blu/Videos"
    "--exclude=/home/blu/.cargo/*"
    "--exclude=/home/blu/.local/share/Steam/steamapps/*"
    "--exclude=/home/blu/.steam/*"
    "--exclude=/home/blu/tmpmount"
    "--exclude=/home/blu/tmpmount2"
    "--exclude=/lost+found/"
    "--exclude=/media/*"
    "--include=/mnt/vm"
    "--exclude=/mnt/*"
    "--exclude=/proc/*"
    "--exclude=/run/*"
    "--exclude=/sys/*"
    "--exclude=/tmp/*"
)

# Function to log messages
log_message() {
    local LOG_FILE="/home/blu/cron_logs/borgbackup.log"
    local TIMESTAMP=$(date +'%Y-%m-%d %H:%M:%S')
    echo "$TIMESTAMP $1" | tee -a "$LOG_FILE"
}

# Perform backup function
perform_backup() {
    BACKUP_TARGET="$1"
    BACKUP_LOCATION="$2"
    SOURCE_DIRS=("${@:3}")

    LOG_FILE="/home/blu/cron_logs/borgbackup.log"
    mkdir -p "/home/blu/cron_logs"  # Ensure the log directory exists

    log_message "Backup to $BACKUP_TARGET start"

    # Extract SSH user, host, and port from BACKUP_LOCATION
    SSH_USER=$(echo "$BACKUP_LOCATION" | sed -n 's#^ssh://\([^@]*\)@\([^:/]*\):\([0-9]*\)/.*#\1#p')
    SSH_HOST=$(echo "$BACKUP_LOCATION" | sed -n 's#^ssh://\([^@]*\)@\([^:/]*\):\([0-9]*\)/.*#\2#p')
    SSH_PORT=$(echo "$BACKUP_LOCATION" | sed -n 's#^ssh://\([^@]*\)@\([^:/]*\):\([0-9]*\)/.*#\3#p')

    if [ -z "$SSH_USER" ] || [ -z "$SSH_HOST" ]; then
        log_message "SSH connection to $BACKUP_TARGET failed: Invalid SSH target format."
        log_message "DEBUG INFO: Extracted User: $SSH_USER, Host: $SSH_HOST, Port: $SSH_PORT"
        return 1
    fi

    # Construct SSH target for testing
    SSH_TARGET="$SSH_USER@$SSH_HOST"

    # Debugging output for SSH_TARGET
    log_message "DEBUG INFO: SSH Target for connection: $SSH_TARGET -p $SSH_PORT"

    # Test SSH connection
    if ssh -q -o BatchMode=yes -o ConnectTimeout=5 -p "$SSH_PORT" "$SSH_TARGET" exit; then
        log_message "SSH connection to $BACKUP_TARGET successful."
    else
        log_message "SSH connection to $BACKUP_TARGET failed."
        return 1
    fi

    log_message "Starting backup with borg..."
    log_message "This may take a while..."

    # Perform the backup
    borg create -v --progress -s  "${COMMON_EXCLUSIONS[@]}" "$BACKUP_LOCATION" "${SOURCE_DIRS[@]}" || {
        log_message "Backup to $BACKUP_TARGET failed with exit code $?"
        # Could add email notification here
        exit 1
    }

    log_message "Backup to $BACKUP_TARGET completed."

    log_message "Included:"
    printf '%s\n' "${SOURCE_DIRS[@]}" | tee -a "$LOG_FILE"

    log_message "Excluded:"
    printf '%s\n' "${COMMON_EXCLUSIONS[@]}" | tee -a "$LOG_FILE"
}

timestamp=$(date --iso-8601=seconds)

# Perform backup to Hetzner Storagebox, this doesn't rely on the mount point
# perform_backup "Hetzner Storagebox - Home Backup" "ssh://u349222@u349222.your-storagebox.de:23/./mainrig-MS-7D51-home-and-var::$timestamp" "/home"

# Check if NAS is mounted before proceeding with NAS backups
if mountpoint -q "/mnt/storage"; then
    log_message "/mnt/storage is already mounted."

# Perform backups to NAS
#  perform_backup "NAS Home Backup mainrig-MS-7D51-home" "ssh://blu@192.168.178.33:22/mnt/storage/disk-backup/mainrig-MS-7D51-home::$timestamp" "/home"

## TODO - implement /mnt/vm backup TODO
 perform_backup "NAS Backup mainrig-MS-7D51-vm" "ssh://blu@192.168.178.33:22/mnt/storage/disk-backup/mainrig-MS-7D51-vm::$timestamp" "/mnt/vm"

else
    log_message "/mnt/storage is not mounted. Skipping NAS backups."
fi

# TODO LEGACY    
    # perform_backup "NAS n Backup mainrig-MS-7D51-n" "ssh://blu@192.168.178.33:22/mnt/storage/disk-backup/mainrig-MS-7D51-n::$timestamp" "/mnt/n"
 


