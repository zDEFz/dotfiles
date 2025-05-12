#!/bin/bash
NON_ROOT_USER="blu"
USER_HOME="/home/$NON_ROOT_USER"
[ -f "$USER_HOME/.secure_env" ] && source "$USER_HOME/.secure_env"

# File and path definitions
db_file="${USER_HOME}/key/DB.kdbx"
output_file="${USER_HOME}/key/DB.kdbx-revisions-pomf.txt"
hash_file="${USER_HOME}/key/DB.kdbx.md5"
remote_url=${UPTAIL_SERVER}/key/DB.kdbx
echo $remote_url

# Check for force upload argument
force_upload=false
if [[ "$1" == "--force" || "$1" == "-f" ]]; then
    force_upload=true
    echo "Force upload enabled. Skipping checks."
fi

# Check for changes using MD5 hash
if ! $force_upload; then
    echo "Calculating current MD5 hash of $db_file..."
    current_hash=$(md5sum "$db_file" | cut -d ' ' -f 1)
    if [ -f $hash_file ]; then
        echo "Reading stored MD5 hash from $hash_file..."
        stored_hash=$(cat $hash_file)
    else
        echo "No previous MD5 hash found. Assuming no previous uploads."
        stored_hash=""
    fi

    # Compare with remote MD5 hash
    echo "Fetching MD5 hash of the remote file..."
    remote_hash=$(curl -s $remote_url | md5sum | cut -d ' ' -f 1)

    # Check if the local file matches the remote file
    if [ "$current_hash" = "$remote_hash" ]; then
        echo "The local file matches the remote file. No need to upload."
        exit 0
    else
        echo "The local file differs from the remote file. Proceeding with upload..."
    fi

    # Skip further checks if hashes match
    if [ "$current_hash" = "$stored_hash" ]; then
        echo "No changes detected in DB.kdbx."
        exit 0
    fi
else
    echo "Force upload skipping MD5 hash checks."
fi

# Proceed with upload
echo "Uploading $db_file to ${UPTAIL_SERVER}/key/DB.kdbx..."
http_code_db=$(curl --progress-bar -o /dev/null -w "%{http_code}" -T "$db_file" -u "${UPTAIL_USER}":"${UPTAIL_UPLOAD_PASS}" "${UPTAIL_SERVER}"/key/DB.kdbx)
if [[ $http_code_db -ge 200 && $http_code_db -lt 300 ]]; then
    echo "DB.kdbx uploaded successfully. HTTP status code: $http_code_db"
else
    echo "Failed to upload DB.kdbx. HTTP status code: $http_code_db"
fi

echo "Updating stored hash..."
current_hash=$(md5sum "$db_file" | cut -d ' ' -f 1)
echo "$current_hash" > $hash_file

echo "Uploading to pomf..."
pomf_url=$(/usr/bin/pomfload "$db_file")
date_stamp=$(date "+%Y-%m-%d %H:%M:%S")
printf "\n%s\n%s\n" "$date_stamp" "$pomf_url" >> $output_file

echo "Uploading $output_file to ${UPTAIL_SERVER}/key/DB.kdbx-revisions-pomf.txt..."
http_code=$(curl --progress-bar -o /dev/null -w "%{http_code}" -T $output_file -u "${UPTAIL_USER}":"${UPTAIL_UPLOAD_PASS}" "${UPTAIL_SERVER}"/key/DB.kdbx-revisions-pomf.txt)
if [[ $http_code -ge 200 && $http_code -lt 210 ]]; then
    echo "Revisions file uploaded successfully. HTTP status code: $http_code"
else
    echo "Failed to upload revisions file. HTTP status code: $http_code"
fi
