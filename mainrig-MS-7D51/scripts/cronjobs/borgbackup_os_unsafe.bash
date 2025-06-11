# Get the device by ID (you need to update these IDs based on your system)
BORG_PASSPHRASE="$(cat /root/.borg-passphrase)"

# Path for backups
BACKUP_DIR="/mnt/storage/disk-backup"
BORG_REPO="ssh://blu@nas.local:22/mnt/storage/disk-backup/mainrig-MS-7D51"

disk=$(readlink -f /dev/disk/by-id/nvme-WD_BLACK_SN850X_8000GB_2452DP4A1Q11)

# OS and Boot partitions
OS_PARTITION=/dev/mapper/root
BOOT_PARTITION=${disk}p1  # Ensure this matches the correct boot partition

# Output file for the partition backup
PARTITION_BACKUP_FILE=$(mktemp --tmpdir=/root partition_backup_XXXXXX.gpt)

# if prev partition backup exist, rm it
[[ -f "$PARTITION_BACKUP_FILE" ]] && rm -f "$PARTITION_BACKUP_FILE"

# Step 1: Backup Partition Table using sgdisk
echo "Backing up partition table..."
sgdisk --backup=$PARTITION_BACKUP_FILE $disk  # Use the entire disk, not a partition or LVM

# Step 3: Backup the Boot Partition (Unencrypted)
echo "Backing up the Boot partition..."
borg create --verbose --progress --stats --read-special $BORG_REPO::boot-partition-backup-{now} $BOOT_PARTITION

# Step 4: Backup the OS Partition (Encrypted Device /dev/mapper/MS-7D51-OS)
echo "Backing up the OS partition..."
borg create --verbose --progress --stats --read-special $BORG_REPO::os-partition-backup-UNSAFE-{now} $OS_PARTITION

# Step 5: Backup the Partition Table (GPT) to Borg
echo "Backing up the partition table to Borg..."
borg create --verbose --progress --stats $BORG_REPO::partition-table-backup-{now} $PARTITION_BACKUP_FILE

# Step 7: Notify success
echo "Backup completed successfully!"

# Step 8: Cleaning up
[[ -f ${PARTIION_BACKUP_FILE} ]] && rm -f ${PARTITION_BACKUP_FILE}
