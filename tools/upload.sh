#!/bin/bash

# Check if both filename and IP address were provided
if [ $# -lt 2 ]; then
    echo "Usage: $0 <filename> <esp32_ip>"
    exit 1
fi

FILE="$1"
ESP32_IP="$2"

# Check if the file exists
if [ ! -f "$FILE" ]; then
    echo "File not found: $FILE"
    exit 1
fi

# Determine file size based on the operating system
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    FILE_SIZE=$(stat -f%z "$FILE")
elif [[ "$OSTYPE" == "msys"* || "$OSTYPE" == "cygwin"* ]]; then
    # Git Bash on Windows
    FILE_SIZE=$(stat --format=%s "$FILE")
else
    # Assume Linux-like behavior
    FILE_SIZE=$(stat -c%s "$FILE")
fi

# Fixed total chunks
TOTAL_CHUNKS=100
CHUNK_SIZE=$(( (FILE_SIZE + TOTAL_CHUNKS - 1) / TOTAL_CHUNKS ))  # Round up to ensure all data is covered

SERVER_URL="http://$ESP32_IP/upload"

echo "Uploading file: $FILE to ESP32 at $ESP32_IP"
echo "File size: $FILE_SIZE bytes"
echo "Total chunks: $TOTAL_CHUNKS"
echo "Calculated chunk size: $CHUNK_SIZE bytes"

for ((i=0; i<TOTAL_CHUNKS; i++)); do
    START_BYTE=$((i * CHUNK_SIZE))
    END_BYTE=$((START_BYTE + CHUNK_SIZE))

    # Calculate the correct size for the last chunk
    if (( END_BYTE > FILE_SIZE )); then
        CHUNK_SIZE_LAST=$((FILE_SIZE - START_BYTE))
        HEADER="chunk-number:$i;total-chunks:$TOTAL_CHUNKS;"

        dd if="$FILE" bs=1 skip=$START_BYTE count=$CHUNK_SIZE_LAST 2>/dev/null | \
        curl -X POST "$SERVER_URL" \
            -H "X-Chunk-Info: $HEADER" \
            --data-binary @- || {
                echo "Chunk $i upload failed."
                exit 1
            }
    else
        HEADER="chunk-number:$i;total-chunks:$TOTAL_CHUNKS;"

        dd if="$FILE" bs=1 skip=$START_BYTE count=$CHUNK_SIZE 2>/dev/null | \
        curl -X POST "$SERVER_URL" \
            -H "X-Chunk-Info: $HEADER" \
            --data-binary @- || {
                echo "Chunk $i upload failed."
                exit 1
            }
    fi

    echo "Chunk $i uploaded."
done

echo "File upload to $ESP32_IP completed successfully."
