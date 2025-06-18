#!/bin/bash

#
# This script fetches a podcast's RSS feed and automatically downloads the
# latest episodes. Default is 10 episodes if not specified.
#

# --- Configuration ---
# The URL of the podcast's RSS feed.
RSS_URL="https://www.omnycontent.com/d/playlist/1e3bd144-9b57-451a-93cf-ac0e00e74446/50382bb4-3af3-4250-8ddc-ac0f0033ceb5/928f134e-3a6c-4738-a134-acbd00746afe/podcast.rss"
# Number of latest episodes to check and download.
EPISODE_COUNT=${1:-10}
# Directory to store downloaded audio files
AUDIO_DIR="audio"

# Create audio directory if it doesn't exist
mkdir -p "$AUDIO_DIR"

echo "Fetching RSS feed for the latest $EPISODE_COUNT episodes..."
echo "-----------------------------------------------------"

# Use curl to get the RSS feed.
# The stream of episode URLs is piped into a while loop.
# `head -n $EPISODE_COUNT` limits the processing to the desired number of episodes.
curl -s "$RSS_URL" | \
    grep '<enclosure' | \
    sed -n 's/.*enclosure url="\([^"]*\)".*/\1/p' | \
    head -n "$EPISODE_COUNT" | \
    while read -r url; do
        # Append the download=true parameter to create a direct download link.
        DOWNLOAD_URL="${url}&download=true"

        echo "Starting download..."
        # Download the file using wget. The --content-disposition flag tells
        # wget to get the correct filename from the server.
        # -P specifies the directory to save the file in
        wget --content-disposition -nc -P "$AUDIO_DIR" "$DOWNLOAD_URL"
        echo "" # Add a blank line for readability
    done

echo "-----------------------------------------------------"
echo "Script finished."
