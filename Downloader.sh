#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Banner
echo -e "${BLUE}"
echo "===================================="
echo "    TERMUX YOUTUBE DOWNLOADER"
echo "===================================="
echo -e "${NC}"

# Function to display help
show_help() {
    echo -e "${YELLOW}Usage:${NC}"
    echo "  ./yt-downloader.sh [URL] [OPTIONS]"
    echo ""
    echo -e "${YELLOW}Options:${NC}"
    echo "  -a, --audio     Download audio only (mp3)"
    echo "  -v, --video     Download video (mp4)"
    echo "  -q, --quality   Video quality (e.g., 720p, 480p)"
    echo "  -h, --help      Show this help"
    echo ""
    echo -e "${YELLOW}Examples:${NC}"
    echo "  ./yt-downloader.sh https://youtube.com/watch?v=xxx"
    echo "  ./yt-downloader.sh https://youtube.com/watch?v=xxx -a"
    echo "  ./yt-downloader.sh https://youtube.com/watch?v=xxx -v -q 720p"
}

# Check if URL is provided
if [ $# -eq 0 ]; then
    echo -e "${RED}Error: No URL provided${NC}"
    show_help
    exit 1
fi

# Default values
URL=""
AUDIO_ONLY=false
VIDEO_ONLY=false
QUALITY="best"
DOWNLOAD_PATH="/sdcard/YouTube_Downloads"

# Create download directory if not exists
mkdir -p "$DOWNLOAD_PATH"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--audio)
            AUDIO_ONLY=true
            shift
            ;;
        -v|--video)
            VIDEO_ONLY=true
            shift
            ;;
        -q|--quality)
            QUALITY="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            URL="$1"
            shift
            ;;
    esac
done

# Validate URL
if [[ ! "$URL" =~ ^https:// ]]; then
    echo -e "${RED}Error: Invalid URL format${NC}"
    exit 1
fi

echo -e "${YELLOW}Starting download...${NC}"
echo -e "${BLUE}URL:${NC} $URL"
echo -e "${BLUE}Download Path:${NC} $DOWNLOAD_PATH"

# Download based on options
cd "$DOWNLOAD_PATH"

if [ "$AUDIO_ONLY" = true ]; then
    echo -e "${GREEN}Downloading audio only...${NC}"
    yt-dlp -x --audio-format mp3 --audio-quality 0 "$URL"
    
elif [ "$VIDEO_ONLY" = true ]; then
    echo -e "${GREEN}Downloading video with quality: $QUALITY${NC}"
    yt-dlp -f "best[height<=${QUALITY//p/}]" "$URL"
    
else
    echo -e "${GREEN}Downloading best available quality...${NC}"
    yt-dlp -f "best" "$URL"
fi

# Check if download was successful
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Download completed successfully!${NC}"
    echo -e "${BLUE}Files saved in:${NC} $DOWNLOAD_PATH"
else
    echo -e "${RED}Download failed!${NC}"
    exit 1
fi
