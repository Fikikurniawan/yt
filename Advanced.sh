#!/bin/bash

# Advanced YouTube Downloader Script

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
DOWNLOAD_DIR="/sdcard/YT_Downloads"
CONFIG_FILE="$HOME/.yt_downloader.conf"

# Load config
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
    else
        # Default config
        DEFAULT_QUALITY="720p"
        DEFAULT_FORMAT="mp4"
        DEFAULT_AUDIO_QUALITY="320k"
    fi
}

# Save config
save_config() {
    cat > "$CONFIG_FILE" << EOF
DEFAULT_QUALITY="$DEFAULT_QUALITY"
DEFAULT_FORMAT="$DEFAULT_FORMAT"
DEFAULT_AUDIO_QUALITY="$DEFAULT_AUDIO_QUALITY"
EOF
}

# Initialize
load_config
mkdir -p "$DOWNLOAD_DIR"

# Functions
show_banner() {
    clear
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════╗"
    echo "║      ADVANCED YT DOWNLOADER         ║"
    echo "║            FOR TERMUX               ║"
    echo "╚══════════════════════════════════════╝"
    echo -e "${NC}"
}

show_menu() {
    echo -e "${YELLOW}Select download type:${NC}"
    echo "1) Video + Audio"
    echo "2) Audio Only (MP3)"
    echo "3) Video Only"
    echo "4) Playlist"
    echo "5) Settings"
    echo "6) Exit"
    echo ""
    read -p "Enter your choice [1-6]: " choice
}

download_video() {
    local url="$1"
    local quality="$2"
    
    echo -e "${BLUE}Downloading video...${NC}"
    yt-dlp -f "bestvideo[height<=${quality}]+bestaudio/best[height<=${quality}]" \
        --merge-output-format mp4 \
        -o "%(title)s.%(ext)s" \
        "$url"
}

download_audio() {
    local url="$1"
    local quality="$2"
    
    echo -e "${GREEN}Downloading audio...${NC}"
    yt-dlp -x \
        --audio-format mp3 \
        --audio-quality "$quality" \
        -o "%(title)s.%(ext)s" \
        "$url"
}

download_playlist() {
    local url="$1"
    local type="$2"
    
    echo -e "${PURPLE}Downloading playlist...${NC}"
    
    if [ "$type" = "audio" ]; then
        yt-dlp -x \
            --audio-format mp3 \
            --audio-quality "$DEFAULT_AUDIO_QUALITY" \
            -o "%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s" \
            "$url"
    else
        yt-dlp -f "bestvideo[height<=${DEFAULT_QUALITY}]+bestaudio/best[height<=${DEFAULT_QUALITY}]" \
            --merge-output-format mp4 \
            -o "%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s" \
            "$url"
    fi
}

settings_menu() {
    while true; do
        clear
        echo -e "${CYAN}SETTINGS${NC}"
        echo "1) Default Video Quality: $DEFAULT_QUALITY"
        echo "2) Default Audio Quality: $DEFAULT_AUDIO_QUALITY"
        echo "3) Download Directory: $DOWNLOAD_DIR"
        echo "4) Back to Main Menu"
        
        read -p "Select option [1-4]: " setting_choice
        
        case $setting_choice in
            1)
                read -p "Enter default video quality (e.g., 720p, 480p, 360p): " DEFAULT_QUALITY
                save_config
                ;;
            2)
                read -p "Enter default audio quality (e.g., 320k, 256k, 192k): " DEFAULT_AUDIO_QUALITY
                save_config
                ;;
            3)
                read -p "Enter download directory: " DOWNLOAD_DIR
                mkdir -p "$DOWNLOAD_DIR"
                save_config
                ;;
            4)
                break
                ;;
            *)
                echo -e "${RED}Invalid option!${NC}"
                ;;
        esac
    done
}

# Main program
main() {
    while true; do
        show_banner
        show_menu
        
        case $choice in
            1|2|3|4)
                read -p "Enter YouTube URL: " url
                
                if [ -z "$url" ]; then
                    echo -e "${RED}URL cannot be empty!${NC}"
                    sleep 2
                    continue
                fi
                
                cd "$DOWNLOAD_DIR"
                
                case $choice in
                    1)
                        download_video "$url" "$DEFAULT_QUALITY"
                        ;;
                    2)
                        download_audio "$url" "$DEFAULT_AUDIO_QUALITY"
                        ;;
                    3)
                        echo -e "${YELLOW}Downloading video only...${NC}"
                        yt-dlp -f "bestvideo[height<=${DEFAULT_QUALITY}]" "$url"
                        ;;
                    4)
                        echo -e "${PURPLE}"
                        echo "1) Download as Video"
                        echo "2) Download as Audio"
                        read -p "Select playlist type [1-2]: " playlist_type
                        echo -e "${NC}"
                        
                        if [ "$playlist_type" = "1" ]; then
                            download_playlist "$url" "video"
                        else
                            download_playlist "$url" "audio"
                        fi
                        ;;
                esac
                
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}Download completed!${NC}"
                else
                    echo -e "${RED}Download failed!${NC}"
                fi
                
                echo ""
                read -p "Press Enter to continue..."
                ;;
            5)
                settings_menu
                ;;
            6)
                echo -e "${GREEN}Goodbye!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid choice!${NC}"
                sleep 2
                ;;
        esac
    done
}

# Run main function
main