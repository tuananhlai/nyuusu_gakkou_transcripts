#!/bin/bash

#
# This script converts all .mp3 files from a specified audio directory to .mp4
# video files with a black screen in the current directory. It checks for
# existing .mp4 files and skips any .mp3s that have already been converted.
# It also handles keyboard interrupts gracefully.
#

# --- Configuration ---
# The directory where your .mp3 files are located.
AUDIO_DIR="audio"
# You can change the resolution of the output video here.
# Common options: 1280x720 (720p), 1920x1080 (1080p)
RESOLUTION="960x540"
# You can change the background color here.
COLOR="black"

# --- Interrupt Handling ---
# Function to run when the script is interrupted (Ctrl+C)
cleanup() {
    echo -e "\n\nProcess interrupted by user. Exiting."
    exit 1
}
# Trap Ctrl+C (SIGINT) and call the cleanup function
trap cleanup SIGINT

# --- Main Script Logic ---
# Check if the audio directory exists
if [ ! -d "$AUDIO_DIR" ]; then
    echo "Error: Audio directory '$AUDIO_DIR/' not found."
    exit 1
fi

# Counter for processed files
PROCESSED_COUNT=0
SKIPPED_COUNT=0
# Suppress error message if no files are found
TOTAL_FILES=$(ls -1q "$AUDIO_DIR"/*.mp3 2>/dev/null | wc -l)

echo "Starting conversion process for $TOTAL_FILES MP3 file(s) from '$AUDIO_DIR/' directory..."
echo "-----------------------------------------------------"

# Loop through every file ending with .mp3 in the audio directory.
for input_path in "$AUDIO_DIR"/*.mp3; do
    # If no files are found, the loop runs once with the literal string. This check prevents that.
    [ -e "$input_path" ] || continue

    # Get just the filename (e.g. "episode-01.mp3") from the full path
    file_name=$(basename "$input_path")

    # Get the name without the .mp3 extension (e.g. "episode-01")
    base_name="${file_name%.mp3}"

    # Define the output file in the current directory
    output_file="${base_name}.mp4"

    # Check if a corresponding .mp4 file already exists in the current directory.
    if [ -f "$output_file" ]; then
        # If the MP4 file already exists, print a message and skip it.
        echo "Skipping '$file_name' (Output file '$output_file' already exists)."
        SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
    else
        # If the MP4 file does NOT exist, proceed with the conversion.
        echo "Converting '$file_name' -> '$output_file'..."

        # This command creates a video from the audio.
        # -f lavfi -i color=...: Generates a virtual black video screen.
        # -i "$input_path": Specifies the input audio file from the audio directory.
        # -c:a copy: Directly copies the audio stream, making it fast and preserving quality.
        # -shortest: Ensures the video ends when the audio does.
        # -loglevel error: Hides the verbose ffmpeg output, only showing errors.
        ffmpeg -f lavfi -i color=c=$COLOR:s=$RESOLUTION -i "$input_path" -c:a copy -shortest -loglevel error "$output_file"

        PROCESSED_COUNT=$((PROCESSED_COUNT + 1))
        echo "Finished converting '$file_name'."
    fi
done

echo "-----------------------------------------------------"
echo "Process complete."
echo "Converted: $PROCESSED_COUNT new file(s)."
echo "Skipped: $SKIPPED_COUNT existing file(s)."