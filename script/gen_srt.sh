#!/bin/bash

#
# This script automatically generates SRT subtitle files for any MP3s in the
# audio/ directory that don't already have one.
# It uses OpenAI's Whisper for transcription.
#

# --- Configuration ---
# Set the language for transcription.
# A list of supported languages can be found in the Whisper documentation.
LANGUAGE="Japanese"

# --- Main Script Logic ---
# Counter for processed files
PROCESSED_COUNT=0

# Create audio directory if it doesn't exist
mkdir -p "audio"

# Loop through every file ending with .mp3 in the audio directory.
for file in audio/*.mp3; do
    # Skip if no files match
    [ -e "$file" ] || continue

    # Remove the leading 'audio/' from the filename
    file_cleaned=$(basename "$file")

    # Get the filename without the .mp3 extension.
    base_name="${file_cleaned%.mp3}"

    # Check if a corresponding .srt file already exists.
    if [ ! -f "${base_name}.srt" ]; then
        # If the SRT file does NOT exist, then proceed with transcription.
        echo "-----------------------------------------------------"
        echo "Found MP3 without subtitles: '$file_cleaned'"
        echo "Starting transcription with Whisper..."

        # Run the Whisper command.
        whisper "$file" --language "$LANGUAGE" --model turbo -f srt

        echo "Finished processing '$file_cleaned'."
        PROCESSED_COUNT=$((PROCESSED_COUNT + 1))
    else
        # If the SRT file already exists, print a message and skip to the next file.
        echo "Skipping '$file_cleaned' (subtitles already exist)."
    fi

done

echo "-----------------------------------------------------"
if [ "$PROCESSED_COUNT" -eq 0 ]; then
    echo "All MP3 files already have subtitles. No new files were processed."
else
    echo "Script finished. Processed $PROCESSED_COUNT new file(s)."
fi