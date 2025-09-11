#!/bin/bash

# Cursux - Advanced Linux Cursor Manager
# Version 314 - mise à jour  le 11/09/2025 à 21h30
# Author: PapaOursPolaire on GitHub

set -euo pipefail

# Global Configuration
readonly CURSUX_VERSION="3.0.0"
readonly CURSUX_DIR="$HOME/.cursux"
readonly CURSORS_DIR="$CURSUX_DIR/cursors"
readonly CUSTOM_DIR="$CURSUX_DIR/custom"
readonly TEMP_DIR="$CURSUX_DIR/temp"
readonly BACKUP_DIR="$CURSUX_DIR/backup"
readonly CACHE_DIR="$CURSUX_DIR/cache"
readonly REPO_DIR="$CURSUX_DIR/repository"
readonly CONFIG_FILE="$CURSUX_DIR/config.json"
readonly LOG_FILE="$CURSUX_DIR/cursux.log"

# GitHub Repository Configuration
readonly GITHUB_API_BASE="https://api.github.com"
readonly GITHUB_RAW_BASE="https://raw.githubusercontent.com"

# Default Cursor Repositories
readonly -a DEFAULT_CURSORS_REPOS=(
    "ful1e5/Bibata_Cursor"
    "keeferrourke/capitaine-cursors"
    "vinceliuice/McMojave-cursors"
    "alvatip/Nordzy-cursors"
    "phisch/phinger-cursors"
    "KDE/breeze"
    "GNOME/adwaita-icon-theme"
)

# Colors and Styling
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly GRAY='\033[0;90m'
readonly BOLD='\033[1m'
readonly UNDERLINE='\033[4m'
readonly NC='\033[0m'

# Icons and Symbols (using ASCII alternatives for better compatibility)
readonly ICON_SUCCESS="[OK]"
readonly ICON_ERROR="[ERROR]"
readonly ICON_WARNING="[WARN]"
readonly ICON_INFO="[INFO]"
readonly ICON_DOWNLOAD="[DOWN]"
readonly ICON_UPLOAD="[UP]"
readonly ICON_CREATE="[NEW]"
readonly ICON_DELETE="[DEL]"
readonly ICON_APPLY="[APPLY]"
readonly ICON_BACKUP="[BACKUP]"
readonly ICON_RESTORE="[RESTORE]"
readonly ICON_UPDATE="[UPDATE]"
readonly ICON_SEARCH="[SEARCH]"
readonly ICON_LIST="[LIST]"
readonly ICON_CONFIG="[CONFIG]"
readonly ICON_HELP="[HELP]"

# Internationalization strings
declare -A LANG_STRINGS=(
    ["welcome"]="Welcome to Cursux - Advanced Linux Cursor Manager"
    ["current_cursor"]="Current cursor"
    ["no_cursors_found"]="No cursors found"
    ["cursor_applied"]="Cursor applied successfully"
    ["cursor_created"]="Custom cursor created successfully"
    ["operation_cancelled"]="Operation cancelled"
    ["invalid_option"]="Invalid option"
    ["file_not_found"]="File not found"
    ["download_complete"]="Download complete"
    ["conversion_complete"]="Conversion complete"
)

# Global variables
CURSUX_GITHUB_USER="${CURSUX_GITHUB_USER:-}"
CURSUX_GITHUB_REPO="${CURSUX_GITHUB_REPO:-}"
DEBUG_MODE="${CURSUX_DEBUG:-0}"

# Logging function
log_message() {
    local level="$1"
    local message="$2"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    
    case "$level" in
        "ERROR")
            echo -e "${RED}${ICON_ERROR} $message${NC}" >&2
            ;;
        "WARNING")
            echo -e "${YELLOW}${ICON_WARNING} $message${NC}"
            ;;
        "SUCCESS")
            echo -e "${GREEN}${ICON_SUCCESS} $message${NC}"
            ;;
        "INFO")
            echo -e "${BLUE}${ICON_INFO} $message${NC}"
            ;;
        "DEBUG")
            if [ "$DEBUG_MODE" = "1" ]; then
                echo -e "${GRAY}[DEBUG] $message${NC}"
            fi
            ;;
    esac
}

# Enhanced logo display
show_logo() {
    clear
    echo -e "${PURPLE}${BOLD}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║          ██████╗██╗   ██╗██████╗ ███████╗██╗   ██╗██╗  ██╗    ║
║         ██╔════╝██║   ██║██╔══██╗██╔════╝██║   ██║╚██╗██╔╝    ║
║         ██║     ██║   ██║██████╔╝███████╗██║   ██║ ╚███╔╝     ║
║         ██║     ██║   ██║██╔══██╗╚════██║██║   ██║ ██╔██╗     ║
║         ╚██████╗╚██████╔╝██║  ██║███████║╚██████╔╝██╔╝ ██╗    ║
║          ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝    ║
║                                                              ║
║              Linux Cursor Manager Advanced v3.0.0           ║
║               Professional Alternative to Custom Cursor     ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Extended help function
show_help() {
    cat << EOF
${WHITE}${BOLD}CURSUX - Advanced Linux Cursor Manager v$CURSUX_VERSION${NC}

${CYAN}${BOLD}USAGE:${NC}
  cursux [OPTION] [ARGUMENTS]

${CYAN}${BOLD}MAIN OPTIONS:${NC}
  ${GREEN}-i, --install${NC}       Install/Download cursors
  ${GREEN}-c, --create${NC}        Create custom cursor
  ${GREEN}-l, --list${NC}          List available cursors
  ${GREEN}-a, --apply${NC}         Apply cursor
  ${GREEN}-r, --remove${NC}        Remove cursor
  ${GREEN}-s, --search${NC}        Search cursors
  ${GREEN}--convert${NC}           Convert Windows cursors (.cur/.ani) to Linux
  ${GREEN}--animate${NC}           Create animated cursor from GIF/video

${CYAN}${BOLD}DATA MANAGEMENT:${NC}
  ${GREEN}-b, --backup${NC}        Backup configuration
  ${GREEN}--restore${NC}           Restore backup
  ${GREEN}--export${NC}            Export cursor to .cursuxpack
  ${GREEN}--import${NC}            Import .cursuxpack file

${CYAN}${BOLD}GITHUB REPOSITORY:${NC}
  ${GREEN}--repo-sync${NC}         Sync with GitHub repository
  ${GREEN}--repo-search${NC}       Search in repository
  ${GREEN}--repo-install${NC}      Install from repository
  ${GREEN}--setup-repo${NC}        Configure GitHub repository

${CYAN}${BOLD}EFFECTS AND ANIMATION:${NC}
  ${GREEN}--effects${NC}           Apply effects (shadow, color, etc.)
  ${GREEN}--batch${NC}             Batch processing
  ${GREEN}--resize${NC}            Resize cursors

${CYAN}${BOLD}CONFIGURATION:${NC}
  ${GREEN}--config${NC}            Edit configuration
  ${GREEN}-u, --update${NC}        Update Cursux
  ${GREEN}--debug${NC}             Verbose debug mode
  ${GREEN}--cleanup${NC}           Clean cache and temp files
  ${GREEN}-h, --help${NC}          Show this help
  ${GREEN}-v, --version${NC}       Show version

${YELLOW}${BOLD}EXAMPLES:${NC}
  ${CYAN}cursux --create image.png --size 32 --hotspot 16,16${NC}
  ${CYAN}cursux --convert windows_cursor.cur${NC}
  ${CYAN}cursux --animate animation.gif --fps 10${NC}
  ${CYAN}cursux --repo-search "minimal"${NC}
  ${CYAN}cursux --effects --shadow --color "#ff0000"${NC}
  ${CYAN}cursux --batch --input-dir ./cursors --output-dir ./converted${NC}

${PURPLE}${BOLD}ENVIRONMENT VARIABLES:${NC}
  ${CYAN}CURSUX_GITHUB_USER${NC}  - GitHub username
  ${CYAN}CURSUX_GITHUB_REPO${NC}  - Repository name
  ${CYAN}CURSUX_DEBUG${NC}        - Enable debug mode (1/0)
EOF
}

# Enhanced dependency checking
check_dependencies() {
    local -a deps_required=("curl" "jq" "convert" "file")
    local -a deps_optional=("dialog" "whiptail" "git" "ffmpeg" "gifsicle" "xcursorgen")
    local -a missing_required=()
    local -a missing_optional=()
    
    log_message "INFO" "Checking dependencies..."
    
    # Check required dependencies
    for dep in "${deps_required[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_required+=("$dep")
        fi
    done
    
    # Check optional dependencies
    for dep in "${deps_optional[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_optional+=("$dep")
        fi
    done
    
    if [ ${#missing_required[@]} -ne 0 ]; then
        log_message "ERROR" "Missing required dependencies: ${missing_required[*]}"
        echo -e "${YELLOW}Install them with:${NC}"
        echo "  ${CYAN}Ubuntu/Debian:${NC} sudo apt install curl jq imagemagick file"
        echo "  ${CYAN}Fedora:${NC} sudo dnf install curl jq ImageMagick file"
        echo "  ${CYAN}Arch:${NC} sudo pacman -S curl jq imagemagick file"
        echo "  ${CYAN}openSUSE:${NC} sudo zypper install curl jq ImageMagick file"
        exit 1
    fi
    
    if [ ${#missing_optional[@]} -ne 0 ]; then
        log_message "WARNING" "Missing optional dependencies: ${missing_optional[*]}"
        echo -e "${YELLOW}${ICON_INFO} Some advanced features may not be available${NC}"
        echo -e "${CYAN}To enable all features, install:${NC}"
        echo "  ${CYAN}Ubuntu/Debian:${NC} sudo apt install dialog git ffmpeg gifsicle x11-apps"
        echo "  ${CYAN}Fedora:${NC} sudo dnf install dialog git ffmpeg gifsicle xorg-x11-apps"
        echo "  ${CYAN}Arch:${NC} sudo pacman -S dialog git ffmpeg gifsicle xorg-xsetroot"
    fi
    
    log_message "SUCCESS" "Dependency check completed"
}

# Initialize JSON configuration
init_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        cat > "$CONFIG_FILE" << EOF
{
    "version": "$CURSUX_VERSION",
    "cursux_dir": "$CURSUX_DIR",
    "current_cursor": "",
    "cursor_size": 24,
    "cursor_theme_path": "$HOME/.local/share/icons",
    "backup_count": 10,
    "github": {
        "user": "$CURSUX_GITHUB_USER",
        "repository": "$CURSUX_GITHUB_REPO",
        "auto_sync": false,
        "last_sync": ""
    },
    "display": {
        "show_preview": true,
        "use_colors": true,
        "animation_preview": true
    },
    "effects": {
        "default_shadow": false,
        "default_shadow_color": "#000000",
        "default_shadow_opacity": 0.5,
        "default_shadow_blur": 2
    },
    "advanced": {
        "parallel_downloads": true,
        "cache_enabled": true,
        "cache_size_mb": 100,
        "debug_mode": false,
        "log_level": "INFO"
    },
    "shortcuts": {
        "quick_apply": true,
        "remember_last": true,
        "auto_backup": true
    },
    "desktop_environments": {
        "gnome": true,
        "kde": true,
        "xfce": true,
        "mate": true,
        "cinnamon": true
    }
}
EOF
        log_message "SUCCESS" "Default configuration created"
    fi
}

# Complete initialization
init_cursux() {
    echo -e "${BLUE}${ICON_CONFIG} Initializing Cursux...${NC}"
    
    # Create all directories
    local -a directories=("$CURSORS_DIR" "$CUSTOM_DIR" "$TEMP_DIR" "$BACKUP_DIR" "$CACHE_DIR" "$REPO_DIR")
    for dir in "${directories[@]}"; do
        mkdir -p "$dir"
        log_message "DEBUG" "Created directory: $dir"
    done
    
    # Initialize log file
    touch "$LOG_FILE"
    
    # Create JSON configuration
    init_config
    
    # Create index files
    echo '{"cursors": [], "last_updated": ""}' > "$REPO_DIR/index.json"
    echo '{"favorites": [], "recent": [], "installed": []}' > "$CURSUX_DIR/user_data.json"
    
    log_message "SUCCESS" "Cursux initialized successfully"
}

# Detect desktop environment
detect_desktop_environment() {
    local de="unknown"
    
    if [ -n "${XDG_CURRENT_DESKTOP:-}" ]; then
        de="$XDG_CURRENT_DESKTOP"
    elif [ -n "${DESKTOP_SESSION:-}" ]; then
        de="$DESKTOP_SESSION"
    elif command -v gnome-shell &> /dev/null; then
        de="GNOME"
    elif command -v plasmashell &> /dev/null; then
        de="KDE"
    elif command -v xfce4-panel &> /dev/null; then
        de="XFCE"
    elif command -v mate-panel &> /dev/null; then
        de="MATE"
    elif command -v cinnamon &> /dev/null; then
        de="Cinnamon"
    fi
    
    echo "$de"
}

# Advanced cursor search
search_cursors() {
    local query="$1"
    local search_type="${2:-all}" # all, local, remote, favorites
    
    if [ -z "$query" ]; then
        read -p "Search term: " query
    fi
    
    if [ -z "$query" ]; then
        log_message "ERROR" "Search term required"
        return 1
    fi
    
    echo -e "${CYAN}${ICON_SEARCH} Searching: '$query'${NC}"
    echo ""
    
    case "$search_type" in
        "local"|"all")
            search_local_cursors "$query"
            ;;
    esac
    
    case "$search_type" in
        "remote"|"all")
            search_remote_cursors "$query"
            ;;
    esac
    
    case "$search_type" in
        "favorites"|"all")
            search_favorites "$query"
            ;;
    esac
}

# Search local cursors
search_local_cursors() {
    local query="$1"
    local found=false
    
    echo -e "${WHITE}${BOLD}Local matching cursors:${NC}"
    
    # Search in custom cursors
    if [ -d "$CUSTOM_DIR" ]; then
        for cursor_dir in "$CUSTOM_DIR"/*; do
            if [ -d "$cursor_dir" ]; then
                local cursor_name
                cursor_name=$(basename "$cursor_dir")
                if [[ "$cursor_name" == *"$query"* ]]; then
                    echo "  ${GREEN}* $cursor_name${NC} (custom)"
                    found=true
                fi
            fi
        done
    fi
    
    # Search in downloaded cursors
    if [ -d "$CURSORS_DIR" ]; then
        for cursor_dir in "$CURSORS_DIR"/*; do
            if [ -d "$cursor_dir" ]; then
                local cursor_name
                cursor_name=$(basename "$cursor_dir")
                if [[ "$cursor_name" == *"$query"* ]]; then
                    echo "  ${BLUE}* $cursor_name${NC} (downloaded)"
                    found=true
                fi
            fi
        done
    fi
    
    if [ "$found" = false ]; then
        echo "  ${YELLOW}No local cursors found${NC}"
    fi
    
    echo ""
}

# Windows cursor conversion
convert_windows_cursor() {
    local input_file="$1"
    local output_name="$2"
    
    if [ -z "$input_file" ]; then
        echo -e "${RED}${ICON_ERROR} Input file required${NC}"
        echo "Usage: cursux --convert <file.cur|file.ani> [output_name]"
        return 1
    fi
    
    if [ ! -f "$input_file" ]; then
        log_message "ERROR" "File not found: $input_file"
        return 1
    fi
    
    # Detect file type
    local file_type
    file_type=$(file -b --mime-type "$input_file")
    local base_name
    base_name=$(basename "$input_file" | sed 's/\.[^.]*$//')
    output_name="${output_name:-$base_name}"
    
    echo -e "${BLUE}${ICON_DOWNLOAD} Converting Windows cursor...${NC}"
    echo "  ${CYAN}File:${NC} $input_file"
    echo "  ${CYAN}Type:${NC} $file_type"
    echo "  ${CYAN}Output:${NC} $output_name"
    echo ""
    
    local temp_png="$TEMP_DIR/${base_name}.png"
    local output_dir="$CUSTOM_DIR/$output_name"
    local cursors_dir="$output_dir/cursors"
    
    mkdir -p "$cursors_dir"
    
    # Convert based on type
    case "$file_type" in
        *"x-cursor"*|*"cursor"*)
            # .cur file - use ImageMagick
            if ! convert "$input_file[0]" "$temp_png" 2>/dev/null; then
                log_message "ERROR" "Unable to convert .cur file"
                return 1
            fi
            ;;
        *"x-win-bitmap"*|*"bitmap"*)
            # .ani or bitmap file
            if ! convert "$input_file" "$temp_png" 2>/dev/null; then
                log_message "ERROR" "Unable to convert bitmap file"
                return 1
            fi
            ;;
        *)
            log_message "ERROR" "Unsupported file type: $file_type"
            return 1
            ;;
    esac
    
    if [ ! -f "$temp_png" ]; then
        log_message "ERROR" "Conversion failed"
        return 1
    fi
    
    # Get image dimensions
    local dimensions
    dimensions=$(identify -format "%wx%h" "$temp_png" 2>/dev/null)
    local width height
    width=$(echo "$dimensions" | cut -d'x' -f1)
    height=$(echo "$dimensions" | cut -d'x' -f2)
    
    echo -e "${YELLOW}Detected dimensions: ${width}x${height}${NC}"
    
    # Get conversion parameters
    echo "Converted cursor configuration:"
    read -p "Cursor size (default: $width): " cursor_size
    cursor_size=${cursor_size:-$width}
    
    read -p "Hotspot X (default: $((width/2))): " hotspot_x
    hotspot_x=${hotspot_x:-$((width/2))}
    
    read -p "Hotspot Y (default: $((height/2))): " hotspot_y
    hotspot_y=${hotspot_y:-$((height/2))}
    
    # Resize if necessary
    if [ "$cursor_size" != "$width" ]; then
        convert "$temp_png" -resize "${cursor_size}x${cursor_size}" "$temp_png"
    fi
    
    # Create xcursor configuration file
    cat > "$TEMP_DIR/cursor.conf" << EOF
$cursor_size $hotspot_x $hotspot_y $temp_png
EOF
    
    # Generate all cursor types
    local -a cursor_types=("default" "pointer" "hand1" "hand2" "text" "wait" "crosshair" "help" "not-allowed" "move")
    
    echo -e "${YELLOW}${ICON_CREATE} Generating cursors...${NC}"
    for cursor_type in "${cursor_types[@]}"; do
        if command -v xcursorgen &> /dev/null; then
            xcursorgen "$TEMP_DIR/cursor.conf" "$cursors_dir/$cursor_type"
        else
            # Fallback: copy PNG files for environments that support them
            cp "$temp_png" "$cursors_dir/$cursor_type.png"
        fi
        echo "  ${GREEN}✓${NC} $cursor_type"
    done
    
    # Create symbolic links
    create_cursor_symlinks "$cursors_dir"
    
    # Create theme file
    create_cursor_theme_file "$output_dir" "$output_name" "Cursor converted from Windows"
    
    log_message "SUCCESS" "Windows cursor converted: $output_name"
    
    # Offer to apply
    read -p "Apply this cursor now? (y/N): " apply_now
    if [[ "$apply_now" =~ ^[yYoO]$ ]]; then
        apply_cursor "$output_name"
    fi
    
    # Clean up
    rm -f "$temp_png" "$TEMP_DIR/cursor.conf"
}

# Create animated cursor from GIF
create_animated_cursor() {
    local gif_file="$1"
    local output_name="$2"
    local fps="${3:-10}"
    
    if [ -z "$gif_file" ]; then
        echo -e "${RED}${ICON_ERROR} GIF file required${NC}"
        return 1
    fi
    
    if [ ! -f "$gif_file" ]; then
        log_message "ERROR" "GIF file not found: $gif_file"
        return 1
    fi
    
    if ! command -v gifsicle &> /dev/null; then
        log_message "ERROR" "gifsicle required for animated cursors"
        echo "Install with: sudo apt install gifsicle"
        return 1
    fi
    
    local base_name
    base_name=$(basename "$gif_file" .gif)
    output_name="${output_name:-${base_name}_animated}"
    
    echo -e "${BLUE}${ICON_CREATE} Creating animated cursor...${NC}"
    echo "  ${CYAN}Source:${NC} $gif_file"
    echo "  ${CYAN}Name:${NC} $output_name"
    echo "  ${CYAN}FPS:${NC} $fps"
    
    local output_dir="$CUSTOM_DIR/$output_name"
    local cursors_dir="$output_dir/cursors"
    local frames_dir="$TEMP_DIR/frames"
    
    mkdir -p "$cursors_dir" "$frames_dir"
    
    # Extract frames from GIF
    echo -e "${YELLOW}${ICON_DOWNLOAD} Extracting frames...${NC}"
    gifsicle --explode "$gif_file" --output "$frames_dir/frame"
    
    local frame_count
    frame_count=$(find "$frames_dir" -name "frame.*.gif" 2>/dev/null | wc -l)
    
    if [ "$frame_count" -eq 0 ]; then
        log_message "ERROR" "Unable to extract frames from GIF"
        return 1
    fi
    
    echo "  ${GREEN}$frame_count frames extracted${NC}"
    
    # Convert each frame to PNG
    echo -e "${YELLOW}Converting frames...${NC}"
    local -a frame_files=()
    for frame_file in "$frames_dir"/frame.*.gif; do
        if [ -f "$frame_file" ]; then
            local frame_num
            frame_num=$(basename "$frame_file" .gif | sed 's/frame\.//')
            local png_file
            png_file="$frames_dir/frame_$(printf "%03d" "$frame_num").png"
            convert "$frame_file" "$png_file"
            frame_files+=("$png_file")
            echo "  ${GREEN}✓${NC} Frame $frame_num"
        fi
    done
    
    # Get parameters
    read -p "Cursor size (default: 32): " cursor_size
    cursor_size=${cursor_size:-32}
    
    read -p "Hotspot X (default: 16): " hotspot_x
    hotspot_x=${hotspot_x:-16}
    
    read -p "Hotspot Y (default: 16): " hotspot_y
    hotspot_y=${hotspot_y:-16}
    
    # Create xcursor configuration for animation
    local delay
    delay=$((1000 / fps))
    cat > "$TEMP_DIR/animated.conf" << EOF
EOF
    
    for png_file in "${frame_files[@]}"; do
        # Resize each frame
        convert "$png_file" -resize "${cursor_size}x${cursor_size}" "$png_file"
        echo "$cursor_size $hotspot_x $hotspot_y $png_file $delay" >> "$TEMP_DIR/animated.conf"
    done
    
    # Generate animated cursor
    echo -e "${YELLOW}${ICON_CREATE} Generating animated cursor...${NC}"
    if command -v xcursorgen &> /dev/null; then
        xcursorgen "$TEMP_DIR/animated.conf" "$cursors_dir/default"
    else
        # Fallback for systems without xcursorgen
        log_message "WARNING" "xcursorgen not found, creating static cursor from first frame"
        cp "${frame_files[0]}" "$cursors_dir/default.png"
    fi
    
    # Create copies for all types
    local -a cursor_types=("pointer" "hand1" "hand2" "text" "wait" "crosshair" "help" "not-allowed" "move")
    for cursor_type in "${cursor_types[@]}"; do
        if [ -f "$cursors_dir/default" ]; then
            cp "$cursors_dir/default" "$cursors_dir/$cursor_type"
        else
            cp "$cursors_dir/default.png" "$cursors_dir/$cursor_type.png"
        fi
    done
    
    # Create symbolic links
    create_cursor_symlinks "$cursors_dir"
    
    # Create theme file
    create_cursor_theme_file "$output_dir" "$output_name" "Animated cursor created from GIF"
    
    log_message "SUCCESS" "Animated cursor created: $output_name"
    
    # Clean up
    rm -rf "$frames_dir" "$TEMP_DIR/animated.conf"
    
    # Offer to apply
    read -p "Apply this animated cursor now? (y/N): " apply_now
    if [[ "$apply_now" =~ ^[yYoO]$ ]]; then
        apply_cursor "$output_name"
    fi
}

# Create cursor symbolic links
create_cursor_symlinks() {
    local cursors_dir="$1"
    
    cd "$cursors_dir" || return 1
    
    # Standard X11 links
    ln -sf "default" "left_ptr" 2>/dev/null || true
    ln -sf "pointer" "pointing_hand" 2>/dev/null || true
    ln -sf "text" "ibeam" 2>/dev/null || true
    ln -sf "text" "xterm" 2>/dev/null || true
    ln -sf "wait" "watch" 2>/dev/null || true
    ln -sf "wait" "progress" 2>/dev/null || true
    ln -sf "crosshair" "cross" 2>/dev/null || true
    ln -sf "help" "question_arrow" 2>/dev/null || true
    ln -sf "not-allowed" "forbidden" 2>/dev/null || true
    ln -sf "not-allowed" "no-drop" 2>/dev/null || true
    ln -sf "move" "fleur" 2>/dev/null || true
    ln -sf "move" "size_all" 2>/dev/null || true
    
    # Resize links
    ln -sf "default" "top_left_corner" 2>/dev/null || true
    ln -sf "default" "top_right_corner" 2>/dev/null || true
    ln -sf "default" "bottom_left_corner" 2>/dev/null || true
    ln -sf "default" "bottom_right_corner" 2>/dev/null || true
    ln -sf "default" "left_side" 2>/dev/null || true
    ln -sf "default" "right_side" 2>/dev/null || true
    ln -sf "default" "top_side" 2>/dev/null || true
    ln -sf "default" "bottom_side" 2>/dev/null || true
}

# Create index.theme file
create_cursor_theme_file() {
    local theme_dir="$1"
    local theme_name="$2"
    local theme_description="$3"
    
    cat > "$theme_dir/index.theme" << EOF
[Icon Theme]
Name=$theme_name
Comment=$theme_description
Inherits=default

[Cursor Theme]
Name=$theme_name
EOF
}

# GitHub repository synchronization
sync_github_repository() {
    local github_user github_repo
    github_user=$(jq -r '.github.user' "$CONFIG_FILE" 2>/dev/null || echo "")
    github_repo=$(jq -r '.github.repository' "$CONFIG_FILE" 2>/dev/null || echo "")
    
    if [ -z "$github_user" ] || [ -z "$github_repo" ]; then
        echo -e "${YELLOW}${ICON_WARNING} GitHub repository not configured${NC}"
        echo "Use: cursux --setup-repo"
        return 1
    fi
    
    echo -e "${BLUE}${ICON_DOWNLOAD} Syncing with $github_user/$github_repo...${NC}"
    
    local api_url="$GITHUB_API_BASE/repos/$github_user/$github_repo/contents"
    local temp_index="$TEMP_DIR/repo_index.json"
    
    # Download repository index
    if curl -s "$api_url" > "$temp_index"; then
        echo -e "${GREEN}${ICON_SUCCESS} Repository accessible${NC}"
        
        # Parse available files
        local cursor_files
        cursor_files=$(jq -r '.[] | select(.name | test("\\.(cur|ani|png|gif|zip|tar\\.gz|tar\\.xz)$"; "i")) | .name' "$temp_index" 2>/dev/null || echo "")
        
        if [ -n "$cursor_files" ]; then
            echo -e "${CYAN}Available cursors in repository:${NC}"
            echo "$cursor_files" | nl
            
            # Update local index
            jq --argjson files "$(echo "$cursor_files" | jq -R . | jq -s .)" \
               --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
               '.cursors = $files | .last_updated = $timestamp' \
               "$REPO_DIR/index.json" > "$TEMP_DIR/new_index.json"
            
            mv "$TEMP_DIR/new_index.json" "$REPO_DIR/index.json"
            
            # Update configuration
            jq --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
               '.github.last_sync = $timestamp' \
               "$CONFIG_FILE" > "$TEMP_DIR/new_config.json"
            mv "$TEMP_DIR/new_config.json" "$CONFIG_FILE"
            
            local cursor_count
            cursor_count=$(echo "$cursor_files" | wc -l)
            log_message "SUCCESS" "Sync completed - $cursor_count cursors found"
        else
            echo -e "${YELLOW}${ICON_WARNING} No cursors found in repository${NC}"
        fi
    else
        log_message "ERROR" "Unable to access GitHub repository"
        return 1
    fi
    
    rm -f "$temp_index"
}

# Search remote repository
search_remote_cursors() {
    local query="$1"
    local github_user github_repo
    github_user=$(jq -r '.github.user' "$CONFIG_FILE" 2>/dev/null || echo "")
    github_repo=$(jq -r '.github.repository' "$CONFIG_FILE" 2>/dev/null || echo "")
    
    echo -e "${WHITE}${BOLD}GitHub Repository ($github_user/$github_repo):${NC}"
    
    if [ -z "$github_user" ] || [ -z "$github_repo" ]; then
        echo "  ${YELLOW}Repository not configured${NC}"
        return
    fi
    
    local repo_index="$REPO_DIR/index.json"
    if [ ! -f "$repo_index" ]; then
        echo "  ${YELLOW}Local index not found - use --repo-sync${NC}"
        return
    fi
    
    local matching_cursors
    matching_cursors=$(jq -r ".cursors[] | select(. | test(\"$query\"; \"i\"))" "$repo_index" 2>/dev/null || echo "")
    
    if [ -n "$matching_cursors" ]; then
        echo "$matching_cursors" | while read -r cursor; do
            echo "  ${PURPLE}* $cursor${NC} (repository)"
        done
    else
        echo "  ${YELLOW}No cursors found in repository${NC}"
    fi
    
    echo ""
}

# Install from GitHub repository
install_from_repository() {
    local cursor_name="$1"
    local github_user github_repo
    github_user=$(jq -r '.github.user' "$CONFIG_FILE" 2>/dev/null || echo "")
    github_repo=$(jq -r '.github.repository' "$CONFIG_FILE" 2>/dev/null || echo "")
    
    if [ -z "$github_user" ] || [ -z "$github_repo" ]; then
        log_message "ERROR" "GitHub repository not configured"
        return 1
    fi
    
    if [ -z "$cursor_name" ]; then
        # Show available cursors list
        local repo_index="$REPO_DIR/index.json"
        if [ ! -f "$repo_index" ]; then
            echo -e "${YELLOW}${ICON_WARNING} Sync first with --repo-sync${NC}"
            return 1
        fi
        
        local available_cursors
        available_cursors=$(jq -r '.cursors[]' "$repo_index" 2>/dev/null || echo "")
        if [ -z "$available_cursors" ]; then
            echo -e "${YELLOW}${ICON_WARNING} No cursors available${NC}"
            return 1
        fi
        
        echo -e "${CYAN}Available cursors in repository:${NC}"
        echo "$available_cursors" | nl
        
        local cursor_count
        cursor_count=$(echo "$available_cursors" | wc -l)
        read -p "Choose cursor (1-$cursor_count): " choice
        
        if [ "$choice" -ge 1 ] && [ "$choice" -le "$cursor_count" ]; then
            cursor_name=$(echo "$available_cursors" | sed -n "${choice}p")
        else
            log_message "ERROR" "Invalid choice"
            return 1
        fi
    fi
    
    echo -e "${BLUE}${ICON_DOWNLOAD} Installing '$cursor_name' from repository...${NC}"
    
    local download_url="$GITHUB_RAW_BASE/$github_user/$github_repo/main/$cursor_name"
    local temp_file="$TEMP_DIR/$cursor_name"
    
    if curl -L -o "$temp_file" "$download_url"; then
        echo -e "${GREEN}${ICON_SUCCESS} Download successful${NC}"
        
        # Determine file type and process accordingly
        local file_type
        file_type=$(file -b --mime-type "$temp_file")
        local base_name
        base_name=$(basename "$cursor_name" | sed 's/\.[^.]*$//')
        
        case "$file_type" in
            *"zip"*|*"compressed"*)
                echo -e "${YELLOW}Extracting archive...${NC}"
                extract_and_install_cursor "$temp_file" "$base_name"
                ;;
            *"image/png"*|*"image/jpeg"*)
                echo -e "${YELLOW}Creating cursor from image...${NC}"
                create_cursor_from_image "$temp_file" "$base_name"
                ;;
            *"image/gif"*)
                echo -e "${YELLOW}Creating animated cursor from GIF...${NC}"
                create_animated_cursor "$temp_file" "$base_name"
                ;;
            *"cursor"*)
                echo -e "${YELLOW}Converting Windows cursor...${NC}"
                convert_windows_cursor "$temp_file" "$base_name"
                ;;
            *)
                log_message "WARNING" "Unrecognized file type, attempting archive processing"
                extract_and_install_cursor "$temp_file" "$base_name"
                ;;
        esac
        
        log_message "SUCCESS" "Cursor '$base_name' installed from repository"
        rm -f "$temp_file"
        
    else
        log_message "ERROR" "Download failed"
        return 1
    fi
}

# Process extracted cursor files
process_extracted_cursors() {
    local extracted_dir="$1"
    local cursor_name="$2"
    
    # Look for cursor files in extracted archive
    local cursor_files
    cursor_files=$(find "$extracted_dir" -type f \( -name "*.cur" -o -name "*.ani" -o -name "*.png" -o -name "*.gif" \) 2>/dev/null)
    
    if [ -z "$cursor_files" ]; then
        # Special detection for Custom Cursor packs (install.inf + info.customcur + Normal/Large/ExtraLarge subdirs)
        if [ -f "$extracted_dir/install.inf" ] || [ -f "$extracted_dir/info.customcur" ]; then
            echo -e "${CYAN}Custom Cursor structure detected${NC}"
            
            # Browse known subdirectories
            for variant in Normal Large ExtraLarge; do
                local variant_dir
                variant_dir=$(find "$extracted_dir" -type d -iname "$variant" | head -n1)
                if [ -n "$variant_dir" ]; then
                    echo -e "${YELLOW}Converting files from $variant/ directory${NC}"
                    for cursor_file in "$variant_dir"/*.cur "$variant_dir"/*.ani; do
                        [ -f "$cursor_file" ] || continue
                        local base_name
                        base_name=$(basename "$cursor_file" | sed 's/\.[^.]*$//')
                        convert_windows_cursor "$cursor_file" "${cursor_name}_${variant}_${base_name}"
                    done
                fi
            done
            return 0
        fi
        
        # Fallback: directory containing "cursor"
        local cursor_dirs
        cursor_dirs=$(find "$extracted_dir" -type d -name "*cursor*" 2>/dev/null)
        if [ -n "$cursor_dirs" ]; then
            local first_cursor_dir
            first_cursor_dir=$(echo "$cursor_dirs" | head -n1)
            cp -r "$first_cursor_dir" "$CURSORS_DIR/$cursor_name"
            echo -e "${GREEN}${ICON_SUCCESS} Structured cursor copied${NC}"
        else
            log_message "ERROR" "No cursor files found in archive"
            return 1
        fi
    else
        # Standard processing: each found file is converted
        echo "$cursor_files" | while read -r cursor_file; do
            local file_basename file_name
            file_basename=$(basename "$cursor_file")
            file_name="${file_basename%.*}"
            
            case "$cursor_file" in
                *.cur|*.ani)
                    convert_windows_cursor "$cursor_file" "${cursor_name}_${file_name}"
                    ;;
                *.png|*.jpg|*.jpeg)
                    create_cursor_from_image "$cursor_file" "${cursor_name}_${file_name}"
                    ;;
                *.gif)
                    create_animated_cursor "$cursor_file" "${cursor_name}_${file_name}"
                    ;;
            esac
        done
    fi
}

# Create cursor from simple image
create_cursor_from_image() {
    local image_file="$1"
    local cursor_name="$2"
    local cursor_size="${3:-32}"
    local hotspot_x="${4:-16}"
    local hotspot_y="${5:-16}"
    
    local output_dir="$CUSTOM_DIR/$cursor_name"
    local cursors_dir="$output_dir/cursors"
    
    mkdir -p "$cursors_dir"
    
    # Resize image
    local temp_png="$TEMP_DIR/${cursor_name}_resized.png"
    convert "$image_file" -resize "${cursor_size}x${cursor_size}" "$temp_png"
    
    # Create configuration file
    cat > "$TEMP_DIR/cursor.conf" << EOF
$cursor_size $hotspot_x $hotspot_y $temp_png
EOF
    
    # Generate all cursor types
    local -a cursor_types=("default" "pointer" "hand1" "hand2" "text" "wait" "crosshair" "help" "not-allowed" "move")
    
    for cursor_type in "${cursor_types[@]}"; do
        if command -v xcursorgen &> /dev/null; then
            xcursorgen "$TEMP_DIR/cursor.conf" "$cursors_dir/$cursor_type"
        else
            cp "$temp_png" "$cursors_dir/$cursor_type.png"
        fi
    done
    
    # Create symbolic links and theme file
    create_cursor_symlinks "$cursors_dir"
    create_cursor_theme_file "$output_dir" "$cursor_name" "Cursor created from image"
    
    # Clean up
    rm -f "$temp_png" "$TEMP_DIR/cursor.conf"
}

# Visual effects system
apply_cursor_effects() {
    local cursor_path="$1"
    local effects_config="$2"
    
    if [ ! -f "$cursor_path" ]; then
        log_message "ERROR" "Cursor file not found: $cursor_path"
        return 1
    fi
    
    echo -e "${BLUE}${ICON_CREATE} Applying visual effects...${NC}"
    
    # Parse effects configuration
    local shadow=false
    local shadow_color="#000000"
    local shadow_opacity="0.5"
    local shadow_blur="2"
    local tint_color=""
    local brightness="1.0"
    local contrast="1.0"
    
    # Interactive mode if no configuration provided
    if [ -z "$effects_config" ]; then
        echo -e "${CYAN}Effects configuration:${NC}"
        
        read -p "Add drop shadow? (y/N): " add_shadow
        if [[ "$add_shadow" =~ ^[yYoO]$ ]]; then
            shadow=true
            read -p "Shadow color (hex, default: #000000): " shadow_color
            shadow_color=${shadow_color:-#000000}
            read -p "Opacity (0.0-1.0, default: 0.5): " shadow_opacity
            shadow_opacity=${shadow_opacity:-0.5}
            read -p "Blur (pixels, default: 2): " shadow_blur
            shadow_blur=${shadow_blur:-2}
        fi
        
        read -p "Tint with color (hex, optional): " tint_color
        read -p "Brightness (0.5-2.0, default: 1.0): " brightness
        brightness=${brightness:-1.0}
        read -p "Contrast (0.5-2.0, default: 1.0): " contrast
        contrast=${contrast:-1.0}
    fi
    
    local temp_image="$TEMP_DIR/cursor_effects.png"
    
    # Convert cursor to temporary image
    if ! convert "$cursor_path" "$temp_image" 2>/dev/null; then
        log_message "ERROR" "Unable to convert cursor to image"
        return 1
    fi
    
    # Apply effects
    local convert_cmd="convert $temp_image"
    
    # Adjust brightness and contrast
    if [ "$brightness" != "1.0" ] || [ "$contrast" != "1.0" ]; then
        local brightness_percent
        brightness_percent=$(echo "$brightness * 100" | bc 2>/dev/null || echo "100")
        convert_cmd="$convert_cmd -modulate ${brightness_percent%.*},100,100"
        convert_cmd="$convert_cmd -sigmoidal-contrast ${contrast}x50%"
        echo -e "${YELLOW}  Adjusting brightness/contrast${NC}"
    fi
    
    # Apply tint
    if [ -n "$tint_color" ]; then
        convert_cmd="$convert_cmd -colorize 30%,$tint_color"
        echo -e "${YELLOW}  Applying tint: $tint_color${NC}"
    fi
    
    # Add drop shadow
    if [ "$shadow" = true ]; then
        convert_cmd="$convert_cmd \\( +clone -background '$shadow_color' -shadow ${shadow_opacity}x${shadow_blur}+2+2 \\) +swap -background none -layers merge +repage"
        echo -e "${YELLOW}  Adding drop shadow${NC}"
    fi
    
    convert_cmd="$convert_cmd $temp_image"
    
    # Execute effects command
    if eval "$convert_cmd"; then
        echo -e "${GREEN}${ICON_SUCCESS} Effects applied successfully${NC}"
    else
        log_message "ERROR" "Failed to apply effects"
        return 1
    fi
}

# Export cursor pack
export_cursor_pack() {
    local cursor_name="$1"
    local output_file="$2"
    
    if [ -z "$cursor_name" ]; then
        echo -e "${CYAN}Available cursors for export:${NC}"
        list_cursors
        read -p "Cursor name to export: " cursor_name
    fi
    
    if [ -z "$cursor_name" ]; then
        log_message "ERROR" "Cursor name required"
        return 1
    fi
    
    # Find cursor
    local cursor_path="" cursor_type=""
    if [ -d "$CUSTOM_DIR/$cursor_name" ]; then
        cursor_path="$CUSTOM_DIR/$cursor_name"
        cursor_type="custom"
    elif [ -d "$CURSORS_DIR/$cursor_name" ]; then
        cursor_path="$CURSORS_DIR/$cursor_name"
        cursor_type="downloaded"
    else
        log_message "ERROR" "Cursor '$cursor_name' not found"
        return 1
    fi
    
    output_file="${output_file:-$cursor_name.cursuxpack}"
    
    echo -e "${BLUE}${ICON_UPLOAD} Exporting '$cursor_name' to '$output_file'...${NC}"
    
    local temp_dir="$TEMP_DIR/export_$cursor_name"
    mkdir -p "$temp_dir"
    
    # Copy cursor files
    cp -r "$cursor_path"/* "$temp_dir/"
    
    # Create metadata file
    cat > "$temp_dir/manifest.json" << EOF
{
    "name": "$cursor_name",
    "version": "1.0",
    "author": "$(whoami)",
    "description": "Cursor exported with Cursux",
    "created": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "cursux_version": "$CURSUX_VERSION",
    "type": "cursor_pack",
    "files": $(find "$temp_dir" -type f ! -name "manifest.json" -printf '"%P"\n' | jq -s . 2>/dev/null || echo '[]')
}
EOF
    
    # Create archive
    (cd "$temp_dir" && tar -czf "../$output_file" .) || {
        log_message "ERROR" "Failed to create archive"
        return 1
    }
    mv "$TEMP_DIR/$output_file" "./$output_file"
    
    # Calculate checksum
    local checksum
    checksum=$(sha256sum "$output_file" | cut -d' ' -f1)
    echo "$checksum" > "${output_file}.sha256"
    
    log_message "SUCCESS" "Cursor exported: $output_file"
    echo -e "${CYAN}SHA256 checksum: $checksum${NC}"
    
    # Clean up
    rm -rf "$temp_dir"
}

# Import cursor pack
import_cursor_pack() {
    local pack_file="$1"
    
    if [ -z "$pack_file" ]; then
        read -p "Path to .cursuxpack file: " pack_file
    fi
    
    if [ ! -f "$pack_file" ]; then
        log_message "ERROR" "File not found: $pack_file"
        return 1
    fi
    
    echo -e "${BLUE}${ICON_DOWNLOAD} Importing '$pack_file'...${NC}"
    
    # Verify checksum if available
    local checksum_file="${pack_file}.sha256"
    if [ -f "$checksum_file" ]; then
        echo -e "${YELLOW}Verifying integrity...${NC}"
        if ! sha256sum -c "$checksum_file"; then
            log_message "ERROR" "Integrity verification failed"
            read -p "Continue anyway? (y/N): " continue_anyway
            if [[ ! "$continue_anyway" =~ ^[yYoO]$ ]]; then
                return 1
            fi
        else
            echo -e "${GREEN}${ICON_SUCCESS} Integrity verified${NC}"
        fi
    fi
    
    local temp_dir
    temp_dir="$TEMP_DIR/import_$(basename "$pack_file" .cursuxpack)"
    mkdir -p "$temp_dir"
    
    # Extract archive
    if tar -xzf "$pack_file" -C "$temp_dir" 2>/dev/null; then
        # Read metadata
        local manifest="$temp_dir/manifest.json"
        if [ -f "$manifest" ]; then
            local cursor_name cursor_version cursor_author cursor_description
            cursor_name=$(jq -r '.name' "$manifest")
            cursor_version=$(jq -r '.version' "$manifest")
            cursor_author=$(jq -r '.author' "$manifest")
            cursor_description=$(jq -r '.description' "$manifest")
            
            echo -e "${CYAN}Pack information:${NC}"
            echo "  ${WHITE}Name:${NC} $cursor_name"
            echo "  ${WHITE}Version:${NC} $cursor_version"
            echo "  ${WHITE}Author:${NC} $cursor_author"
            echo "  ${WHITE}Description:${NC} $cursor_description"
            echo ""
            
            # Check if cursor already exists
            if [ -d "$CUSTOM_DIR/$cursor_name" ]; then
                echo -e "${YELLOW}${ICON_WARNING} Cursor '$cursor_name' already exists${NC}"
                read -p "Replace? (y/N): " replace_existing
                if [[ ! "$replace_existing" =~ ^[yYoO]$ ]]; then
                    log_message "INFO" "Import cancelled"
                    rm -rf "$temp_dir"
                    return 0
                fi
                rm -rf "$CUSTOM_DIR/$cursor_name"
            fi
            
            # Copy files
            mkdir -p "$CUSTOM_DIR/$cursor_name"
            cp -r "$temp_dir"/* "$CUSTOM_DIR/$cursor_name/"
            rm -f "$CUSTOM_DIR/$cursor_name/manifest.json" # Remove manifest from installation
            
            log_message "SUCCESS" "Cursor '$cursor_name' imported successfully"
            
            # Offer to apply
            read -p "Apply this cursor now? (y/N): " apply_now
            if [[ "$apply_now" =~ ^[yYoO]$ ]]; then
                apply_cursor "$cursor_name"
            fi
            
        else
            log_message "ERROR" "manifest.json missing from pack"
            return 1
        fi
    else
        log_message "ERROR" "Unable to extract archive"
        return 1
    fi
    
    # Clean up
    rm -rf "$temp_dir"
}

# Batch processing
batch_process() {
    local input_dir="$1"
    local output_dir="$2"
    local operation="$3" # convert, resize, effects
    
    if [ -z "$input_dir" ] || [ ! -d "$input_dir" ]; then
        log_message "ERROR" "Input directory required and must exist"
        return 1
    fi
    
    output_dir="${output_dir:-$input_dir/processed}"
    mkdir -p "$output_dir"
    
    echo -e "${BLUE}${ICON_CREATE} Batch processing: $operation${NC}"
    echo "  ${CYAN}Input:${NC} $input_dir"
    echo "  ${CYAN}Output:${NC} $output_dir"
    
    local processed=0 failed=0
    
    # Find all cursor files
    while IFS= read -r -d '' file; do
        echo -e "\n${YELLOW}Processing: $(basename "$file")${NC}"
        
        local base_name
        base_name=$(basename "$file" | sed 's/\.[^.]*$//')
        
        case "$operation" in
            "convert")
                if convert_windows_cursor "$file" "$base_name"; then
                    ((processed++))
                else
                    ((failed++))
                fi
                ;;
            "resize")
                read -p "New size for $(basename "$file") (default: 32): " new_size
                new_size=${new_size:-32}
                if create_cursor_from_image "$file" "$base_name" "$new_size"; then
                    ((processed++))
                else
                    ((failed++))
                fi
                ;;
            "effects")
                if apply_cursor_effects "$file"; then
                    ((processed++))
                else
                    ((failed++))
                fi
                ;;
            *)
                log_message "ERROR" "Unsupported operation: $operation"
                return 1
                ;;
        esac
        
    done < <(find "$input_dir" -type f \( -name "*.cur" -o -name "*.ani" -o -name "*.png" -o -name "*.gif" \) -print0)
    
    echo -e "\n${GREEN}${ICON_SUCCESS} Processing complete${NC}"
    echo "  ${WHITE}Successfully processed:${NC} $processed"
    echo "  ${WHITE}Failed:${NC} $failed"
}

# GitHub repository setup
setup_github_repository() {
    echo -e "${BLUE}${ICON_CONFIG} GitHub repository configuration${NC}"
    echo ""
    
    local current_user current_repo
    current_user=$(jq -r '.github.user' "$CONFIG_FILE" 2>/dev/null || echo "")
    current_repo=$(jq -r '.github.repository' "$CONFIG_FILE" 2>/dev/null || echo "")
    
    if [ -n "$current_user" ] && [ -n "$current_repo" ]; then
        echo -e "${CYAN}Current configuration:${NC}"
        echo "  ${WHITE}User:${NC} $current_user"
        echo "  ${WHITE}Repository:${NC} $current_repo"
        echo ""
    fi
    
    read -p "GitHub username: " github_user
    read -p "Repository name: " github_repo
    
    if [ -z "$github_user" ] || [ -z "$github_repo" ]; then
        log_message "ERROR" "Username and repository required"
        return 1
    fi
    
    # Check repository accessibility
    echo -e "${YELLOW}${ICON_SEARCH} Checking repository...${NC}"
    local test_url="$GITHUB_API_BASE/repos/$github_user/$github_repo"
    
    if curl -s "$test_url" | jq -e '.name' > /dev/null 2>&1; then
        echo -e "${GREEN}${ICON_SUCCESS} Repository accessible${NC}"
        
        # Update configuration
        jq --arg user "$github_user" --arg repo "$github_repo" \
           '.github.user = $user | .github.repository = $repo' \
           "$CONFIG_FILE" > "$TEMP_DIR/new_config.json"
        mv "$TEMP_DIR/new_config.json" "$CONFIG_FILE"
        
        log_message "SUCCESS" "Repository configured: $github_user/$github_repo"
        
        # Offer synchronization
        read -p "Sync now? (y/N): " sync_now
        if [[ "$sync_now" =~ ^[yYoO]$ ]]; then
            sync_github_repository
        fi
        
    else
        log_message "ERROR" "Repository inaccessible or non-existent"
        echo "Check that repository $github_user/$github_repo exists and is public"
        return 1
    fi
}

# Enhanced cursor application with multi-environment support
apply_cursor() {
    local cursor_name="$1"
    
    if [ -z "$cursor_name" ]; then
        echo -e "${CYAN}${ICON_LIST} Available cursors:${NC}"
        list_cursors
        echo ""
        read -p "Cursor name to apply: " cursor_name
    fi
    
    if [ -z "$cursor_name" ]; then
        log_message "ERROR" "Cursor name required"
        return 1
    fi
    
    # Find cursor
    local cursor_path="" cursor_type=""
    
    if [ -d "$CUSTOM_DIR/$cursor_name" ]; then
        cursor_path="$CUSTOM_DIR/$cursor_name"
        cursor_type="custom"
    elif [ -d "$CURSORS_DIR/$cursor_name" ]; then
        cursor_path="$CURSORS_DIR/$cursor_name"
        cursor_type="downloaded"
    elif [ -d "/usr/share/icons/$cursor_name" ]; then
        cursor_path="/usr/share/icons/$cursor_name"
        cursor_type="system"
    elif [ -d "$HOME/.local/share/icons/$cursor_name" ]; then
        cursor_path="$HOME/.local/share/icons/$cursor_name"
        cursor_type="user"
    else
        log_message "ERROR" "Cursor '$cursor_name' not found"
        return 1
    fi
    
    echo -e "${BLUE}${ICON_APPLY} Applying cursor '$cursor_name' ($cursor_type)...${NC}"
    
    # Backup current configuration
    backup_current_config
    
    # Detect desktop environment
    local desktop_env
    desktop_env=$(detect_desktop_environment)
    echo -e "${CYAN}Detected environment: $desktop_env${NC}"
    
    # Copy cursor if necessary
    mkdir -p "$HOME/.local/share/icons"
    if [ "$cursor_path" != "$HOME/.local/share/icons/$cursor_name" ]; then
        cp -r "$cursor_path" "$HOME/.local/share/icons/"
    fi
    
    # Apply based on desktop environment
    local applied=false
    
    case "$desktop_env" in
        *"GNOME"*|*"Unity"*)
            if command -v gsettings &> /dev/null; then
                gsettings set org.gnome.desktop.interface cursor-theme "$cursor_name"
                log_message "SUCCESS" "Cursor applied via gsettings (GNOME)"
                applied=true
            fi
            ;;
        *"KDE"*|*"Plasma"*)
            if command -v kwriteconfig5 &> /dev/null; then
                kwriteconfig5 --file ~/.config/kcminputrc --group Mouse --key cursorTheme "$cursor_name"
                kwriteconfig5 --file ~/.config/kdeglobals --group Icons --key Theme "$cursor_name"
                log_message "SUCCESS" "Cursor applied via kwriteconfig5 (KDE)"
                applied=true
            elif command -v kwriteconfig6 &> /dev/null; then
                kwriteconfig6 --file ~/.config/kcminputrc --group Mouse --key cursorTheme "$cursor_name"
                kwriteconfig6 --file ~/.config/kdeglobals --group Icons --key Theme "$cursor_name"
                log_message "SUCCESS" "Cursor applied via kwriteconfig6 (KDE)"
                applied=true
            fi
            ;;
        *"XFCE"*)
            if command -v xfconf-query &> /dev/null; then
                xfconf-query -c xsettings -p /Gtk/CursorThemeName -s "$cursor_name"
                log_message "SUCCESS" "Cursor applied via xfconf-query (XFCE)"
                applied=true
            fi
            ;;
        *"MATE"*)
            if command -v dconf &> /dev/null; then
                dconf write /org/mate/desktop/peripherals/mouse/cursor-theme "'$cursor_name'"
                log_message "SUCCESS" "Cursor applied via dconf (MATE)"
                applied=true
            fi
            ;;
        *"Cinnamon"*)
            if command -v dconf &> /dev/null; then
                dconf write /org/cinnamon/desktop/interface/cursor-theme "'$cursor_name'"
                log_message "SUCCESS" "Cursor applied via dconf (Cinnamon)"
                applied=true
            fi
            ;;
    esac
    
    # Fallback for all environments - GTK configuration
    update_gtk_config "$cursor_name"
    
    # Direct X11 application
    if command -v xsetroot &> /dev/null; then
        XCURSOR_THEME="$cursor_name" xsetroot -cursor_name left_ptr 2>/dev/null || true
    fi
    
    # Update Cursux configuration
    jq --arg cursor "$cursor_name" --arg path "$cursor_path" --arg type "$cursor_type" \
       '.current_cursor = $cursor | .last_applied = {name: $cursor, path: $path, type: $type, date: (now | strftime("%Y-%m-%d %H:%M:%S"))}' \
       "$CONFIG_FILE" > "$TEMP_DIR/new_config.json"
    mv "$TEMP_DIR/new_config.json" "$CONFIG_FILE"
    
    # Add to recent cursors
    add_to_recent_cursors "$cursor_name"
    
    if [ "$applied" = true ]; then
        log_message "SUCCESS" "Cursor '$cursor_name' applied successfully!"
        echo -e "${YELLOW}${ICON_INFO} Restart applications to see all changes${NC}"
    else
        log_message "WARNING" "Partial application - some environments may require logout/login"
    fi
}

# Update GTK configuration files
update_gtk_config() {
    local cursor_name="$1"
    
    # GTK 2
    local gtk2_config="$HOME/.gtkrc-2.0"
    if [ -f "$gtk2_config" ]; then
        sed -i '/gtk-cursor-theme-name/d' "$gtk2_config"
    fi
    echo "gtk-cursor-theme-name=\"$cursor_name\"" >> "$gtk2_config"
    
    # GTK 3
    local gtk3_config="$HOME/.config/gtk-3.0/settings.ini"
    mkdir -p "$(dirname "$gtk3_config")"
    
    if [ -f "$gtk3_config" ]; then
        sed -i '/gtk-cursor-theme-name/d' "$gtk3_config"
    else
        echo "[Settings]" > "$gtk3_config"
    fi
    echo "gtk-cursor-theme-name=$cursor_name" >> "$gtk3_config"
    
    # GTK 4
    local gtk4_config="$HOME/.config/gtk-4.0/settings.ini"
    mkdir -p "$(dirname "$gtk4_config")"
    
    if [ -f "$gtk4_config" ]; then
        sed -i '/gtk-cursor-theme-name/d' "$gtk4_config"
    else
        echo "[Settings]" > "$gtk4_config"
    fi
    echo "gtk-cursor-theme-name=$cursor_name" >> "$gtk4_config"
    
    log_message "INFO" "GTK configuration updated"
}

# Add to recent cursors
add_to_recent_cursors() {
    local cursor_name="$1"
    local user_data_file="$CURSUX_DIR/user_data.json"
    
    if [ ! -f "$user_data_file" ]; then
        echo '{"favorites": [], "recent": [], "installed": []}' > "$user_data_file"
    fi
    
    # Update recent cursors list
    jq --arg cursor "$cursor_name" \
        '.recent = ([$cursor] + (.recent - [$cursor])) | 
         .recent = .recent[0:10]' \
        "$user_data_file" > "$TEMP_DIR/new_user_data.json"
    
    if [ $? -eq 0 ]; then
        mv "$TEMP_DIR/new_user_data.json" "$user_data_file"
    else
        rm -f "$TEMP_DIR/new_user_data.json"
    fi
}

# Favorites management
manage_favorites() {
    local action="$1" # add, remove, list
    local cursor_name="$2"
    
    local user_data_file="$CURSUX_DIR/user_data.json"
    
    if [ ! -f "$user_data_file" ]; then
        echo '{"favorites": [], "recent": [], "installed": []}' > "$user_data_file"
    fi
    
    case "$action" in
        "add")
            if [ -z "$cursor_name" ]; then
                read -p "Cursor name to add to favorites: " cursor_name
            fi
            
            if [ -n "$cursor_name" ]; then
                jq --arg cursor "$cursor_name" \
                   '.favorites |= (. + [$cursor]) | .favorites |= unique' \
                   "$user_data_file" > "$TEMP_DIR/new_user_data.json"
                mv "$TEMP_DIR/new_user_data.json" "$user_data_file"
                log_message "SUCCESS" "'$cursor_name' added to favorites"
            fi
            ;;
        "remove")
            if [ -z "$cursor_name" ]; then
                echo -e "${CYAN}Current favorites:${NC}"
                jq -r '.favorites[]' "$user_data_file" 2>/dev/null | nl
                read -p "Cursor name to remove from favorites: " cursor_name
            fi
            
            if [ -n "$cursor_name" ]; then
                jq --arg cursor "$cursor_name" \
                   '.favorites |= (. - [$cursor])' \
                   "$user_data_file" > "$TEMP_DIR/new_user_data.json"
                mv "$TEMP_DIR/new_user_data.json" "$user_data_file"
                log_message "SUCCESS" "'$cursor_name' removed from favorites"
            fi
            ;;
        "list")
            echo -e "${CYAN}${ICON_LIST} Favorite cursors:${NC}"
            local favorites
            favorites=$(jq -r '.favorites[]' "$user_data_file" 2>/dev/null || echo "")
            
            if [ -n "$favorites" ]; then
                echo "$favorites" | while read -r fav; do
                    echo "  ${YELLOW}* $fav${NC}"
                done
            else
                echo "  ${GRAY}No favorites${NC}"
            fi
            ;;
    esac
}

# Search favorites
search_favorites() {
    local query="$1"
    local user_data_file="$CURSUX_DIR/user_data.json"
    
    echo -e "${WHITE}${BOLD}Matching favorites:${NC}"
    
    if [ ! -f "$user_data_file" ]; then
        echo "  ${YELLOW}No favorites${NC}"
        return
    fi
    
    local matching_favorites
    matching_favorites=$(jq -r ".favorites[] | select(. | test(\"$query\"; \"i\"))" "$user_data_file" 2>/dev/null || echo "")
    
    if [ -n "$matching_favorites" ]; then
        echo "$matching_favorites" | while read -r fav; do
            echo "  ${YELLOW}* $fav${NC} (favorite)"
        done
    else
        echo "  ${YELLOW}No matching favorites${NC}"
    fi
}

# Enhanced backup with metadata
backup_current_config() {
    local backup_name="$1"
    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)
    backup_name="${backup_name:-backup_$timestamp}"
    
    local backup_file="$BACKUP_DIR/$backup_name.json"
    
    echo -e "${YELLOW}${ICON_BACKUP} Backing up configuration...${NC}"
    
    # Collect all configuration information
    local current_cursor=""
    
    if command -v gsettings &> /dev/null; then
        current_cursor=$(gsettings get org.gnome.desktop.interface cursor-theme 2>/dev/null | tr -d "'" || echo "default")
    fi
    
    # Read GTK configurations
    local gtk2_cursor gtk3_cursor
    gtk2_cursor=$(grep "gtk-cursor-theme-name" "$HOME/.gtkrc-2.0" 2>/dev/null | cut -d'"' -f2 || echo "")
    gtk3_cursor=$(grep "gtk-cursor-theme-name" "$HOME/.config/gtk-3.0/settings.ini" 2>/dev/null | cut -d'=' -f2 || echo "")
    
    # Create complete backup
    cat > "$backup_file" << EOF
{
    "backup_info": {
        "name": "$backup_name",
        "date": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
        "cursux_version": "$CURSUX_VERSION",
        "desktop_environment": "$(detect_desktop_environment)"
    },
    "cursor_config": {
        "current_cursor": "$current_cursor",
        "gtk2_cursor": "$gtk2_cursor",
        "gtk3_cursor": "$gtk3_cursor"
    },
    "files_backup": {
        "gtkrc_2": $(if [ -f "$HOME/.gtkrc-2.0" ]; then cat "$HOME/.gtkrc-2.0" | jq -Rs .; else echo "null"; fi),
        "gtk3_settings": $(if [ -f "$HOME/.config/gtk-3.0/settings.ini" ]; then cat "$HOME/.config/gtk-3.0/settings.ini" | jq -Rs .; else echo "null"; fi)
    },
    "user_data": $(cat "$CURSUX_DIR/user_data.json" 2>/dev/null || echo '{"favorites": [], "recent": [], "installed": []}')
}
EOF
    
    log_message "SUCCESS" "Backup created: $backup_file"
    
    # Clean old backups (keep 10 most recent)
    local backup_count
    backup_count=$(jq -r '.backup_count // 10' "$CONFIG_FILE")
    local old_backups
    old_backups=$(ls -1t "$BACKUP_DIR"/*.json 2>/dev/null | tail -n +$((backup_count + 1)) || echo "")
    
    if [ -n "$old_backups" ]; then
        echo "$old_backups" | while read -r old_backup; do
            rm -f "$old_backup"
            log_message "INFO" "Old backup removed: $(basename "$old_backup")"
        done
    fi
}

# Enhanced backup restoration
restore_backup() {
    echo -e "${CYAN}${ICON_RESTORE} Available backups:${NC}"
    
    local backup_files
    backup_files=$(find "$BACKUP_DIR" -name "*.json" -type f 2>/dev/null | sort -r)
    
    if [ -z "$backup_files" ]; then
        log_message "WARNING" "No backups found"
        return 1
    fi
    
    echo ""
    local i=1
    echo "$backup_files" | while read -r backup_file; do
        local backup_info
        backup_info=$(jq -r '.backup_info' "$backup_file" 2>/dev/null)
        
        if [ "$backup_info" != "null" ]; then
            local backup_name backup_date backup_desktop
            backup_name=$(echo "$backup_info" | jq -r '.name')
            backup_date=$(echo "$backup_info" | jq -r '.date')
            backup_desktop=$(echo "$backup_info" | jq -r '.desktop_environment')
            echo "  $i. $backup_name ($backup_date) [$backup_desktop]"
        else
            # Old format
            local backup_name
            backup_name=$(basename "$backup_file" .json)
            echo "  $i. $backup_name (legacy format)"
        fi
        i=$((i + 1))
    done
    
    echo ""
    local choice
    local backup_count
    backup_count=$(echo "$backup_files" | wc -l)
    read -p "Choose backup to restore (1-$backup_count): " choice
    
    if [ "$choice" -ge 1 ] && [ "$choice" -le "$backup_count" ]; then
        local backup_file
        backup_file=$(echo "$backup_files" | sed -n "${choice}p")
        echo -e "${BLUE}${ICON_RESTORE} Restoring backup...${NC}"
        
        # Read backup
        local cursor_config files_backup
        cursor_config=$(jq -r '.cursor_config' "$backup_file" 2>/dev/null)
        files_backup=$(jq -r '.files_backup' "$backup_file" 2>/dev/null)
        
        if [ "$cursor_config" != "null" ] && [ "$files_backup" != "null" ]; then
            # Modern restoration
            local current_cursor
            current_cursor=$(echo "$cursor_config" | jq -r '.current_cursor')
            
            # Restore configuration files
            if [ "$(echo "$files_backup" | jq -r '.gtkrc_2')" != "null" ]; then
                echo "$files_backup" | jq -r '.gtkrc_2' > "$HOME/.gtkrc-2.0"
            fi
            
            if [ "$(echo "$files_backup" | jq -r '.gtk3_settings')" != "null" ]; then
                mkdir -p "$HOME/.config/gtk-3.0"
                echo "$files_backup" | jq -r '.gtk3_settings' > "$HOME/.config/gtk-3.0/settings.ini"
            fi
            
            # Apply cursor
            if [ -n "$current_cursor" ] && [ "$current_cursor" != "null" ]; then
                if command -v gsettings &> /dev/null; then
                    gsettings set org.gnome.desktop.interface cursor-theme "$current_cursor"
                fi
            fi
            
            # Restore user data
            local user_data
            user_data=$(jq -r '.user_data' "$backup_file" 2>/dev/null)
            if [ "$user_data" != "null" ]; then
                echo "$user_data" > "$CURSUX_DIR/user_data.json"
            fi
            
            log_message "SUCCESS" "Backup restored successfully"
            
        else
            # Legacy format compatibility
            log_message "WARNING" "Legacy backup format detected"
        fi
        
    else
        log_message "ERROR" "Invalid choice"
        return 1
    fi
}

# Advanced listing with filters and sorting
list_cursors() {
    local filter="${1:-all}" # all, custom, downloaded, system, favorites, recent
    local sort_by="${2:-name}" # name, date, size, type
    
    echo -e "${CYAN}${ICON_LIST} Available cursors${NC}"
    
    if [ "$filter" != "all" ]; then
        echo -e "${WHITE}Filter: $filter${NC}"
    fi
    
    echo ""
    
    # Custom cursors
    if [ "$filter" = "all" ] || [ "$filter" = "custom" ]; then
        echo -e "${WHITE}${BOLD}Custom cursors:${NC}"
        
        if [ -d "$CUSTOM_DIR" ]; then
            find "$CUSTOM_DIR" -maxdepth 1 -type d ! -path "$CUSTOM_DIR" 2>/dev/null | while read -r cursor_dir; do
                local cursor_name cursor_size cursor_date
                cursor_name=$(basename "$cursor_dir")
                cursor_size=$(du -sh "$cursor_dir" 2>/dev/null | cut -f1)
                cursor_date=$(stat -c %y "$cursor_dir" 2>/dev/null | cut -d' ' -f1)
                
                echo "  ${GREEN}* $cursor_name${NC} ${GRAY}($cursor_size, $cursor_date)${NC}"
            done
        else
            echo "  ${GRAY}No custom cursors${NC}"
        fi
        echo ""
    fi
    
    # Downloaded cursors
    if [ "$filter" = "all" ] || [ "$filter" = "downloaded" ]; then
        echo -e "${WHITE}${BOLD}Downloaded cursors:${NC}"
        
        if [ -d "$CURSORS_DIR" ]; then
            find "$CURSORS_DIR" -maxdepth 1 -type d ! -path "$CURSORS_DIR" 2>/dev/null | while read -r cursor_dir; do
                local cursor_name cursor_size cursor_date
                cursor_name=$(basename "$cursor_dir")
                cursor_size=$(du -sh "$cursor_dir" 2>/dev/null | cut -f1)
                cursor_date=$(stat -c %y "$cursor_dir" 2>/dev/null | cut -d' ' -f1)
                
                echo "  ${BLUE}* $cursor_name${NC} ${GRAY}($cursor_size, $cursor_date)${NC}"
            done
        else
            echo "  ${GRAY}No downloaded cursors${NC}"
        fi
        echo ""
    fi
    
    # System cursors
    if [ "$filter" = "all" ] || [ "$filter" = "system" ]; then
        echo -e "${WHITE}${BOLD}System cursors:${NC}"
        
        local found_system=false
        if [ -d "/usr/share/icons" ]; then
            find "/usr/share/icons" -maxdepth 1 -type d 2>/dev/null | while read -r cursor_dir; do
                if [ -d "$cursor_dir/cursors" ]; then
                    local cursor_name
                    cursor_name=$(basename "$cursor_dir")
                    echo "  ${PURPLE}* $cursor_name${NC} ${GRAY}(system)${NC}"
                    found_system=true
                fi
            done
        fi
        
        if [ "$found_system" = false ]; then
            echo "  ${GRAY}No system cursors with cursors/ structure${NC}"
        fi
        echo ""
    fi
    
    # Favorites
    if [ "$filter" = "all" ] || [ "$filter" = "favorites" ]; then
        local user_data_file="$CURSUX_DIR/user_data.json"
        if [ -f "$user_data_file" ]; then
            local favorites
            favorites=$(jq -r '.favorites[]' "$user_data_file" 2>/dev/null || echo "")
            
            if [ -n "$favorites" ]; then
                echo -e "${WHITE}${BOLD}Favorite cursors:${NC}"
                echo "$favorites" | while read -r fav; do
                    echo "  ${YELLOW}* $fav${NC}"
                done
                echo ""
            fi
        fi
    fi
    
    # Recent
    if [ "$filter" = "all" ] || [ "$filter" = "recent" ]; then
        local user_data_file="$CURSUX_DIR/user_data.json"
        if [ -f "$user_data_file" ]; then
            local recent
            recent=$(jq -r '.recent[]' "$user_data_file" 2>/dev/null || echo "")
            
            if [ -n "$recent" ]; then
                echo -e "${WHITE}${BOLD}Recent cursors:${NC}"
                echo "$recent" | while read -r rec; do
                    echo "  ${CYAN}* $rec${NC}"
                done
                echo ""
            fi
        fi
    fi
    
    # Show current cursor
    local current_cursor
    current_cursor=$(jq -r '.current_cursor // empty' "$CONFIG_FILE" 2>/dev/null)
    if [ -n "$current_cursor" ]; then
        echo -e "${WHITE}${BOLD}Current cursor: ${GREEN}$current_cursor${NC}"
    fi
}

# Advanced removal with confirmation
remove_cursor() {
    local cursor_name="$1"
    local force="${2:-false}"
    
    if [ -z "$cursor_name" ]; then
        echo -e "${CYAN}Removable cursors:${NC}"
        echo ""
        
        echo -e "${WHITE}Custom cursors:${NC}"
        find "$CUSTOM_DIR" -maxdepth 1 -type d ! -path "$CUSTOM_DIR" 2>/dev/null | while read -r cursor; do
            echo "  * $(basename "$cursor")"
        done
        
        echo ""
        echo -e "${WHITE}Downloaded cursors:${NC}"
        find "$CURSORS_DIR" -maxdepth 1 -type d ! -path "$CURSORS_DIR" 2>/dev/null | while read -r cursor; do
            echo "  * $(basename "$cursor")"
        done
        
        echo ""
        read -p "Cursor name to remove: " cursor_name
    fi
    
    if [ -z "$cursor_name" ]; then
        log_message "ERROR" "Cursor name required"
        return 1
    fi
    
    local removed=false
    local -a cursor_paths=()
    
    # Find all cursor locations
    if [ -d "$CUSTOM_DIR/$cursor_name" ]; then
        cursor_paths+=("$CUSTOM_DIR/$cursor_name:custom")
    fi
    
    if [ -d "$CURSORS_DIR/$cursor_name" ]; then
        cursor_paths+=("$CURSORS_DIR/$cursor_name:downloaded")
    fi
    
    if [ -d "$HOME/.local/share/icons/$cursor_name" ]; then
        cursor_paths+=("$HOME/.local/share/icons/$cursor_name:installed")
    fi
    
    if [ ${#cursor_paths[@]} -eq 0 ]; then
        log_message "ERROR" "Cursor '$cursor_name' not found"
        return 1
    fi
    
    # Show what will be removed
    echo -e "${YELLOW}${ICON_WARNING} Cursor '$cursor_name' will be removed from:${NC}"
    for path_info in "${cursor_paths[@]}"; do
        local path="${path_info%:*}"
        local type="${path_info#*:}"
        echo "  ${RED}* $path${NC} ($type)"
    done
    
    if [ "$force" != "true" ]; then
        echo ""
        read -p "Confirm removal? (y/N): " confirm
        if [[ ! "$confirm" =~ ^[yYoO]$ ]]; then
            log_message "INFO" "Removal cancelled"
            return 0
        fi
    fi
    
    # Proceed with removal
    for path_info in "${cursor_paths[@]}"; do
        local path="${path_info%:*}"
        local type="${path_info#*:}"
        
        if rm -rf "$path"; then
            log_message "SUCCESS" "$type cursor removed: $path"
            removed=true
        else
            log_message "ERROR" "Failed to remove: $path"
        fi
    done
    
    # Remove from favorites and recent
    if [ "$removed" = true ]; then
        local user_data_file="$CURSUX_DIR/user_data.json"
        if [ -f "$user_data_file" ]; then
            jq --arg cursor "$cursor_name" \
               '.favorites |= (. - [$cursor]) | .recent |= (. - [$cursor])' \
               "$user_data_file" > "$TEMP_DIR/new_user_data.json"
            mv "$TEMP_DIR/new_user_data.json" "$user_data_file"
        fi
        
        log_message "SUCCESS" "Cursor '$cursor_name' completely removed"
    fi
}

# Enhanced interactive menu
interactive_menu() {
    while true; do
        show_logo
        
        # Display system information
        local current_cursor desktop_env
        current_cursor=$(jq -r '.current_cursor // "none"' "$CONFIG_FILE" 2>/dev/null)
        desktop_env=$(detect_desktop_environment)
        
        echo -e "${CYAN}${BOLD}System Information:${NC}"
        echo "  ${WHITE}Environment:${NC} $desktop_env"
        echo "  ${WHITE}Current cursor:${NC} $current_cursor"
        echo "  ${WHITE}Cursux version:${NC} $CURSUX_VERSION"
        echo ""
        
        echo -e "${CYAN}${BOLD}Main Menu${NC}"
        echo ""
        echo "  ${GREEN}1.${NC}  Install cursors"
        echo "  ${GREEN}2.${NC}  Create custom cursor"
        echo "  ${GREEN}3.${NC}  Create animated cursor (GIF)"
        echo "  ${GREEN}4.${NC}  Convert Windows cursor (.cur/.ani)"
        echo "  ${GREEN}5.${NC}  List cursors"
        echo "  ${GREEN}6.${NC}  Search cursors"
        echo "  ${GREEN}7.${NC}  Apply cursor"
        echo "  ${GREEN}8.${NC}  Remove cursor"
        echo ""
        echo "  ${BLUE}9.${NC}  Manage favorites"
        echo "  ${BLUE}10.${NC} GitHub repository"
        echo "  ${BLUE}11.${NC} Export cursor (.cursuxpack)"
        echo "  ${BLUE}12.${NC} Import cursor (.cursuxpack)"
        echo ""
        echo "  ${PURPLE}13.${NC} Visual effects"
        echo "  ${PURPLE}14.${NC} Batch processing"
        echo "  ${PURPLE}15.${NC} Configuration"
        echo ""
        echo "  ${YELLOW}16.${NC} Backup configuration"
        echo "  ${YELLOW}17.${NC} Restore backup"
        echo "  ${YELLOW}18.${NC} Update Cursux"
        echo "  ${YELLOW}19.${NC} Help and documentation"
        echo ""
        echo "  ${RED}0.${NC}  Exit"
        echo ""
        
        read -p "Choose option (0-19): " choice
        
        case $choice in
            1) install_cursors_menu ;;
            2) create_cursor_menu ;;
            3) create_animated_menu ;;
            4) convert_windows_menu ;;
            5) list_cursors_menu ;;
            6) search_cursors_menu ;;
            7) apply_cursor ;;
            8) remove_cursor ;;
            9) favorites_menu ;;
            10) github_menu ;;
            11) export_cursor_pack ;;
            12) import_cursor_pack ;;
            13) effects_menu ;;
            14) batch_menu ;;
            15) configuration_menu ;;
            16) backup_current_config ;;
            17) restore_backup ;;
            18) update_cursux ;;
            19) show_help | less ;;
            0)
                echo -e "${GREEN}${ICON_SUCCESS} Thank you for using Cursux!${NC}"
                exit 0
                ;;
            *)
                log_message "ERROR" "Invalid option: $choice"
                ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
    done
}

# Submenu functions

# Cursor installation menu
install_cursors_menu() {
    echo -e "${CYAN}${BOLD}Cursor Installation${NC}"
    echo ""
    echo "  ${GREEN}1.${NC} Popular predefined cursors"
    echo "  ${GREEN}2.${NC} From GitHub repository"
    echo "  ${GREEN}3.${NC} Direct URL"
    echo "  ${GREEN}4.${NC} Local file"
    echo "  ${GREEN}0.${NC} Back"
    echo ""
    
    read -p "Choice: " choice
    
    case $choice in
        1) install_popular_cursors ;;
        2) install_from_repository ;;
        3) install_from_url ;;
        4) install_from_file ;;
        0) return ;;
        *) log_message "ERROR" "Invalid option" ;;
    esac
}

# Create cursor menu
create_cursor_menu() {
    echo -e "${CYAN}${BOLD}Create Cursor${NC}"
    echo ""
    
    read -p "Path to image: " image_path
    if [ ! -f "$image_path" ]; then
        log_message "ERROR" "Image file not found"
        return 1
    fi
    
    read -p "Cursor name: " cursor_name
    read -p "Size (default: 32): " cursor_size
    cursor_size=${cursor_size:-32}
    
    read -p "Hotspot X (default: center): " hotspot_x
    hotspot_x=${hotspot_x:-$((cursor_size/2))}
    
    read -p "Hotspot Y (default: center): " hotspot_y
    hotspot_y=${hotspot_y:-$((cursor_size/2))}
    
    create_cursor_from_image "$image_path" "$cursor_name" "$cursor_size" "$hotspot_x" "$hotspot_y"
}

# Create animated cursor menu
create_animated_menu() {
    echo -e "${CYAN}${BOLD}Animated Cursor${NC}"
    echo ""
    
    read -p "Path to GIF: " gif_path
    if [ ! -f "$gif_path" ]; then
        log_message "ERROR" "GIF file not found"
        return 1
    fi
    
    read -p "Animated cursor name: " cursor_name
    read -p "FPS (default: 10): " fps
    fps=${fps:-10}
    
    create_animated_cursor "$gif_path" "$cursor_name" "$fps"
}

# Convert Windows cursor menu
convert_windows_menu() {
    echo -e "${CYAN}${BOLD}Windows Conversion${NC}"
    echo ""
    
    read -p "Path to .cur/.ani file: " windows_file
    if [ ! -f "$windows_file" ]; then
        log_message "ERROR" "File not found"
        return 1
    fi
    
    read -p "Converted cursor name (optional): " cursor_name
    
    convert_windows_cursor "$windows_file" "$cursor_name"
}

# List cursors menu
list_cursors_menu() {
    echo -e "${CYAN}${BOLD}List Cursors${NC}"
    echo ""
    echo "  ${GREEN}1.${NC} All cursors"
    echo "  ${GREEN}2.${NC} Custom cursors"
    echo "  ${GREEN}3.${NC} Downloaded cursors"
    echo "  ${GREEN}4.${NC} System cursors"
    echo "  ${GREEN}5.${NC} Favorites"
    echo "  ${GREEN}6.${NC} Recent"
    echo "  ${GREEN}0.${NC} Back"
    echo ""
    
    read -p "Choice: " choice
    
    case $choice in
        1) list_cursors "all" ;;
        2) list_cursors "custom" ;;
        3) list_cursors "downloaded" ;;
        4) list_cursors "system" ;;
        5) list_cursors "favorites" ;;
        6) list_cursors "recent" ;;
        0) return ;;
        *) log_message "ERROR" "Invalid option" ;;
    esac
}

# Search cursors menu
search_cursors_menu() {
    echo -e "${CYAN}${BOLD}Search Cursors${NC}"
    echo ""
    
    read -p "Search term: " search_term
    if [ -n "$search_term" ]; then
        search_cursors "$search_term"
    fi
}

# Favorites menu
favorites_menu() {
    echo -e "${CYAN}${BOLD}Favorites Management${NC}"
    echo ""
    echo "  ${GREEN}1.${NC} Add to favorites"
    echo "  ${GREEN}2.${NC} Remove from favorites"
    echo "  ${GREEN}3.${NC} List favorites"
    echo "  ${GREEN}0.${NC} Back"
    echo ""
    
    read -p "Choice: " choice
    
    case $choice in
        1) manage_favorites "add" ;;
        2) manage_favorites "remove" ;;
        3) manage_favorites "list" ;;
        0) return ;;
        *) log_message "ERROR" "Invalid option" ;;
    esac
}

# GitHub menu
github_menu() {
    echo -e "${CYAN}${BOLD}GitHub Repository${NC}"
    echo ""
    echo "  ${GREEN}1.${NC} Configure repository"
    echo "  ${GREEN}2.${NC} Synchronize"
    echo "  ${GREEN}3.${NC} Search in repository"
    echo "  ${GREEN}4.${NC} Install from repository"
    echo "  ${GREEN}0.${NC} Back"
    echo ""
    
    read -p "Choice: " choice
    
    case $choice in
        1) setup_github_repository ;;
        2) sync_github_repository ;;
        3) 
            read -p "Search term: " search_term
            search_remote_cursors "$search_term"
            ;;
        4) install_from_repository ;;
        0) return ;;
        *) log_message "ERROR" "Invalid option" ;;
    esac
}

# Effects menu
effects_menu() {
    echo -e "${CYAN}${BOLD}Visual Effects${NC}"
    echo ""
    echo "  ${GREEN}1.${NC} Apply effects to cursor"
    echo "  ${GREEN}2.${NC} Configure default effects"
    echo "  ${GREEN}0.${NC} Back"
    echo ""
    
    read -p "Choice: " choice
    
    case $choice in
        1)
            read -p "Path to cursor: " cursor_path
            apply_cursor_effects "$cursor_path"
            ;;
        2)
            configure_default_effects
            ;;
        0) return ;;
        *) log_message "ERROR" "Invalid option" ;;
    esac
}

# Batch processing menu
batch_menu() {
    echo -e "${CYAN}${BOLD}Batch Processing${NC}"
    echo ""
    echo "  ${GREEN}1.${NC} Convert Windows cursors"
    echo "  ${GREEN}2.${NC} Resize cursors"
    echo "  ${GREEN}3.${NC} Apply effects"
    echo "  ${GREEN}0.${NC} Back"
    echo ""
    
    read -p "Choice: " choice
    
    case $choice in
        1)
            read -p "Input directory: " input_dir
            read -p "Output directory (optional): " output_dir
            batch_process "$input_dir" "$output_dir" "convert"
            ;;
        2)
            read -p "Input directory: " input_dir
            read -p "Output directory (optional): " output_dir
            batch_process "$input_dir" "$output_dir" "resize"
            ;;
        3)
            read -p "Input directory: " input_dir
            read -p "Output directory (optional): " output_dir
            batch_process "$input_dir" "$output_dir" "effects"
            ;;
        0) return ;;
        *) log_message "ERROR" "Invalid option" ;;
    esac
}

# Configuration menu
configuration_menu() {
    echo -e "${CYAN}${BOLD}Configuration${NC}"
    echo ""
    echo "  ${GREEN}1.${NC} Edit JSON configuration"
    echo "  ${GREEN}2.${NC} Reset configuration"
    echo "  ${GREEN}3.${NC} View current configuration"
    echo "  ${GREEN}4.${NC} Configure default effects"
    echo "  ${GREEN}5.${NC} Clean cache"
    echo "  ${GREEN}0.${NC} Back"
    echo ""
    
    read -p "Choice: " choice
    
    case $choice in
        1) edit_configuration ;;
        2) reset_configuration ;;
        3) show_configuration ;;
        4) configure_default_effects ;;
        5) cleanup_cache ;;
        0) return ;;
        *) log_message "ERROR" "Invalid option" ;;
    esac
}

# Install popular cursors
install_popular_cursors() {
    local -a popular_cursors=(
        "Bibata-Modern-Classic:https://github.com/ful1e5/Bibata_Cursor/releases/latest/download/Bibata-Modern-Classic.tar.xz"
        "Bibata-Modern-Ice:https://github.com/ful1e5/Bibata_Cursor/releases/latest/download/Bibata-Modern-Ice.tar.xz"
        "Capitaine-Cursors:https://github.com/keeferrourke/capitaine-cursors/archive/refs/heads/master.zip"
        "McMojave-cursors:https://github.com/vinceliuice/McMojave-cursors/archive/refs/heads/master.zip"
        "Nordzy-cursors:https://github.com/alvatip/Nordzy-cursors/archive/refs/heads/main.zip"
    )
    
    echo -e "${CYAN}Available popular cursors:${NC}"
    for i in "${!popular_cursors[@]}"; do
        local cursor_info="${popular_cursors[$i]}"
        local cursor_name="${cursor_info%%:*}"
        echo "  $((i+1)). $cursor_name"
    done
    echo "  0. All cursors"
    echo ""
    
    read -p "Choose (0-${#popular_cursors[@]}): " choice
    
    if [ "$choice" = "0" ]; then
        for cursor_info in "${popular_cursors[@]}"; do
            install_cursor_from_url "$cursor_info"
        done
    elif [ "$choice" -ge 1 ] && [ "$choice" -le "${#popular_cursors[@]}" ]; then
        local cursor_info="${popular_cursors[$((choice-1))]}"
        install_cursor_from_url "$cursor_info"
    else
        log_message "ERROR" "Invalid choice"
    fi
}

# Install from URL
install_from_url() {
    read -p "Cursor URL: " cursor_url
    if [ -n "$cursor_url" ]; then
        install_cursor_from_url "custom:$cursor_url"
    fi
}

# Install from local file
install_from_file() {
    read -p "File path: " file_path
    if [ -f "$file_path" ]; then
        local base_name
        base_name=$(basename "$file_path" | sed 's/\.[^.]*$//')
        
        case "$file_path" in
            *.cur|*.ani)
                convert_windows_cursor "$file_path" "$base_name"
                ;;
            *.zip|*.tar.gz|*.tar.xz)
                extract_and_install_cursor "$file_path" "$base_name"
                ;;
            *.png|*.jpg|*.jpeg)
                create_cursor_from_image "$file_path" "$base_name"
                ;;
            *.gif)
                create_animated_cursor "$file_path" "$base_name"
                ;;
            *)
                log_message "ERROR" "Unsupported file type"
                ;;
        esac
    else
        log_message "ERROR" "File not found"
    fi
}

# URL installation function
install_cursor_from_url() {
    local cursor_info="$1"
    local cursor_name="${cursor_info%%:*}"
    local cursor_url="${cursor_info#*:}"
    
    if [ "$cursor_name" = "custom" ]; then
        cursor_name=$(basename "$cursor_url" | sed 's/\.[^.]*$//')
    fi
    
    echo -e "${BLUE}${ICON_DOWNLOAD} Downloading $cursor_name...${NC}"
    
    local temp_file="$TEMP_DIR/$(basename "$cursor_url")"
    
    if curl -L --progress-bar -o "$temp_file" "$cursor_url"; then
        echo -e "${GREEN}${ICON_SUCCESS} Download successful${NC}"
        
        # Determine file processing method
        local file_type
        file_type=$(file -b --mime-type "$temp_file")
        
        case "$file_type" in
            *"zip"*)
                extract_and_install_cursor "$temp_file" "$cursor_name"
                ;;
            *"x-xz"*|*"gzip"*)
                extract_and_install_cursor "$temp_file" "$cursor_name"
                ;;
            *)
                log_message "WARNING" "Unrecognized file type, attempting extraction"
                extract_and_install_cursor "$temp_file" "$cursor_name"
                ;;
        esac
        
        rm -f "$temp_file"
    else
        log_message "ERROR" "Download failed"
        return 1
    fi
}

# Archive extraction and installation
extract_and_install_cursor() {
    local archive_file="$1"
    local cursor_name="$2"
    local extract_dir="$TEMP_DIR/extract_$cursor_name"
    
    mkdir -p "$extract_dir"
    
    # Try different extraction methods
    if [[ "$archive_file" == *.zip ]]; then
        unzip -q "$archive_file" -d "$extract_dir"
    elif [[ "$archive_file" == *.tar.xz ]]; then
        tar -xJf "$archive_file" -C "$extract_dir"
    elif [[ "$archive_file" == *.tar.gz ]]; then
        tar -xzf "$archive_file" -C "$extract_dir"
    else
        # Generic attempt
        tar -xf "$archive_file" -C "$extract_dir" 2>/dev/null || \
        unzip -q "$archive_file" -d "$extract_dir" 2>/dev/null || {
            log_message "ERROR" "Unable to extract archive"
            return 1
        }
    fi
    
    # Look for cursor directories
    local cursor_dirs
    cursor_dirs=$(find "$extract_dir" -type d -name "*cursor*" 2>/dev/null)
    
    if [ -n "$cursor_dirs" ]; then
        # Copy first cursor directory found
        local first_cursor_dir
        first_cursor_dir=$(echo "$cursor_dirs" | head -n1)
        cp -r "$first_cursor_dir" "$CURSORS_DIR/$cursor_name"
        log_message "SUCCESS" "Cursor '$cursor_name' installed"
    else
        # Look for individual cursor files
        local cursor_files
        cursor_files=$(find "$extract_dir" -type f \( -name "*.cur" -o -name "*.png" -o -name "*.gif" \) 2>/dev/null)
        
        if [ -n "$cursor_files" ]; then
            process_extracted_cursors "$extract_dir" "$cursor_name"
        else
            log_message "ERROR" "No cursor files found in archive"
            return 1
        fi
    fi
    
    # Clean up
    rm -rf "$extract_dir"
}

# Configure default effects
configure_default_effects() {
    echo -e "${CYAN}${BOLD}Default Effects Configuration${NC}"
    echo ""
    
    local current_shadow current_shadow_color current_shadow_opacity
    current_shadow=$(jq -r '.effects.default_shadow' "$CONFIG_FILE")
    current_shadow_color=$(jq -r '.effects.default_shadow_color' "$CONFIG_FILE")
    current_shadow_opacity=$(jq -r '.effects.default_shadow_opacity' "$CONFIG_FILE")
    
    echo "Current configuration:"
    echo "  Default shadow: $current_shadow"
    echo "  Shadow color: $current_shadow_color"
    echo "  Opacity: $current_shadow_opacity"
    echo ""
    
    read -p "Enable default shadow? (y/n): " enable_shadow
    read -p "Shadow color (hex): " shadow_color
    read -p "Opacity (0.0-1.0): " shadow_opacity
    read -p "Blur (pixels): " shadow_blur
    
    # Update configuration
    jq --argjson shadow "$([ "$enable_shadow" = "y" ] && echo true || echo false)" \
       --arg color "${shadow_color:-$current_shadow_color}" \
       --arg opacity "${shadow_opacity:-$current_shadow_opacity}" \
       --arg blur "${shadow_blur:-2}" \
       '.effects.default_shadow = $shadow |
        .effects.default_shadow_color = $color |
        .effects.default_shadow_opacity = ($opacity | tonumber) |
        .effects.default_shadow_blur = ($blur | tonumber)' \
       "$CONFIG_FILE" > "$TEMP_DIR/new_config.json"
    
    mv "$TEMP_DIR/new_config.json" "$CONFIG_FILE"
    log_message "SUCCESS" "Effects configuration updated"
}

# Edit configuration
edit_configuration() {
    local editor="${EDITOR:-nano}"
    
    echo -e "${BLUE}${ICON_CONFIG} Opening configuration with $editor...${NC}"
    echo -e "${YELLOW}${ICON_WARNING} Warning: Invalid configuration may break Cursux${NC}"
    
    read -p "Continue? (y/N): " continue_edit
    if [[ "$continue_edit" =~ ^[yYoO]$ ]]; then
        # Create backup
        cp "$CONFIG_FILE" "$CONFIG_FILE.backup"
        
        # Open editor
        "$editor" "$CONFIG_FILE"
        
        # Validate JSON configuration
        if jq . "$CONFIG_FILE" >/dev/null 2>&1; then
            log_message "SUCCESS" "Configuration updated and validated"
            rm -f "$CONFIG_FILE.backup"
        else
            log_message "ERROR" "Invalid JSON configuration, restoring backup"
            mv "$CONFIG_FILE.backup" "$CONFIG_FILE"
        fi
    fi
}

# Show configuration
show_configuration() {
    echo -e "${CYAN}${BOLD}Current Configuration${NC}"
    echo ""
    
    if command -v jq &> /dev/null; then
        jq . "$CONFIG_FILE" | sed 's/^/  /'
    else
        cat "$CONFIG_FILE" | sed 's/^/  /'
    fi
}

# Reset configuration
reset_configuration() {
    echo -e "${YELLOW}${ICON_WARNING} This will reset all configuration${NC}"
    read -p "Confirm? (y/N): " confirm
    
    if [[ "$confirm" =~ ^[yYoO]$ ]]; then
        # Backup old configuration
        cp "$CONFIG_FILE" "$BACKUP_DIR/config_backup_$(date +%Y%m%d_%H%M%S).json"
        
        # Create new default configuration
        rm -f "$CONFIG_FILE"
        init_config
        
        log_message "SUCCESS" "Configuration reset"
    fi
}

# Cache cleanup
cleanup_cache() {
    echo -e "${BLUE}${ICON_DELETE} Cleaning cache...${NC}"
    
    local cache_size temp_size
    cache_size=$(du -sh "$CACHE_DIR" 2>/dev/null | cut -f1)
    temp_size=$(du -sh "$TEMP_DIR" 2>/dev/null | cut -f1)
    
    echo "  Current cache: $cache_size"
    echo "  Temp files: $temp_size"
    echo ""
    
    read -p "Clean cache and temp files? (y/N): " confirm
    
    if [[ "$confirm" =~ ^[yYoO]$ ]]; then
        # Clean cache
        rm -rf "$CACHE_DIR"/*
        rm -rf "$TEMP_DIR"/*
        
        # Clean old logs (keep last 100 lines)
        if [ -f "$LOG_FILE" ]; then
            tail -n 100 "$LOG_FILE" > "$TEMP_DIR/log_temp"
            mv "$TEMP_DIR/log_temp" "$LOG_FILE"
        fi
        
        log_message "SUCCESS" "Cache cleaned"
    fi
}

# Update Cursux
update_cursux() {
    echo -e "${BLUE}${ICON_UPDATE} Checking for updates...${NC}"
    
    # In a real scenario, this would download from a repository
    local latest_version="3.0.0"
    
    if [ "$latest_version" = "$CURSUX_VERSION" ]; then
        echo -e "${GREEN}${ICON_SUCCESS} Cursux is up to date (v$CURSUX_VERSION)${NC}"
    else
        echo -e "${YELLOW}New version available: v$latest_version${NC}"
        echo -e "${CYAN}To update manually:${NC}"
        echo "  1. Download latest version"
        echo "  2. Backup your configuration"
        echo "  3. Replace cursux.sh script"
        echo "  4. Restore your configuration"
    fi
    
    echo ""
    echo -e "${CYAN}Useful links:${NC}"
    echo "  Documentation: https://github.com/cursux/cursux/wiki"
    echo "  Report bug: https://github.com/cursux/cursux/issues"
    echo "  Community: https://github.com/cursux/cursux/discussions"
}

# Main function
main() {
    # Check dependencies
    check_dependencies
    
    # Initialize Cursux
    init_cursux
    
    # Debug mode if requested
    if [ "${CURSUX_DEBUG:-0}" = "1" ] || [[ "$*" == *"--debug"* ]]; then
        set -x
        log_message "INFO" "Debug mode activated"
    fi
    
    # Command line argument processing
    case "${1:-}" in
        -i|--install)
            shift
            if [ "${1:-}" = "--popular" ]; then
                install_popular_cursors
            elif [ "${1:-}" = "--url" ]; then
                install_from_url
            elif [ "${1:-}" = "--file" ]; then
                install_from_file
            else
                install_cursors_menu
            fi
            ;;
        -c|--create)
            if [ -n "${2:-}" ]; then
                create_cursor_from_image "$2" "${3:-}" "${4:-}" "${5:-}" "${6:-}"
            else
                create_cursor_menu
            fi
            ;;
        --animate)
            if [ -n "${2:-}" ]; then
                create_animated_cursor "$2" "${3:-}" "${4:-}"
            else
                create_animated_menu
            fi
            ;;
        --convert)
            if [ -n "${2:-}" ]; then
                convert_windows_cursor "$2" "${3:-}"
            else
                convert_windows_menu
            fi
            ;;
        -l|--list)
            list_cursors "${2:-}" "${3:-}"
            ;;
        -a|--apply)
            apply_cursor "${2:-}"
            ;;
        -r|--remove)
            remove_cursor "${2:-}" "${3:-}"
            ;;
        -s|--search)
            search_cursors "${2:-}" "${3:-}"
            ;;
        --favorites)
            manage_favorites "${2:-}" "${3:-}"
            ;;
        --export)
            export_cursor_pack "${2:-}" "${3:-}"
            ;;
        --import)
            import_cursor_pack "${2:-}"
            ;;
        --repo-sync)
            sync_github_repository
            ;;
        --repo-search)
            search_remote_cursors "${2:-}"
            ;;
        --repo-install)
            install_from_repository "${2:-}"
            ;;
        --setup-repo)
            setup_github_repository
            ;;
        --effects)
            apply_cursor_effects "${2:-}" "${3:-}"
            ;;
        --batch)
            batch_process "${2:-}" "${3:-}" "${4:-}"
            ;;
        --config)
            if [ "${2:-}" = "edit" ]; then
                edit_configuration
            elif [ "${2:-}" = "show" ]; then
                show_configuration
            elif [ "${2:-}" = "reset" ]; then
                reset_configuration
            else
                configuration_menu
            fi
            ;;
        -b|--backup)
            backup_current_config "${2:-}"
            ;;
        --restore)
            restore_backup
            ;;
        -u|--update)
            update_cursux
            ;;
        --cleanup)
            cleanup_cache
            ;;
        --debug)
            set -x
            interactive_menu
            ;;
        -h|--help)
            show_help
            ;;
        -v|--version)
            echo "Cursux v$CURSUX_VERSION"
            ;;
        "")
            # Interactive mode by default
            interactive_menu
            ;;
        *)
            log_message "ERROR" "Unknown option: $1"
            echo "Use 'cursux --help' to see available options"
            exit 1
            ;;
    esac
}

# Exit cleanup function
cleanup_on_exit() {
    # Clean temporary files
    find "$TEMP_DIR" -type f -mmin +60 -delete 2>/dev/null || true
    
    # Compress old logs if too large
    if [ -f "$LOG_FILE" ] && [ "$(wc -l < "$LOG_FILE" 2>/dev/null || echo 0)" -gt 1000 ]; then
        tail -n 500 "$LOG_FILE" > "$LOG_FILE.new"
        mv "$LOG_FILE.new" "$LOG_FILE"
    fi
    
    # Clean cache if too large
    local cache_size_mb max_cache_mb
    cache_size_mb=$(du -sm "$CACHE_DIR" 2>/dev/null | cut -f1 || echo 0)
    max_cache_mb=$(jq -r '.advanced.cache_size_mb // 100' "$CONFIG_FILE" 2>/dev/null)
    
    if [ "$cache_size_mb" -gt "$max_cache_mb" ]; then
        find "$CACHE_DIR" -type f -atime +7 -delete 2>/dev/null || true
    fi
}

# Signal handling
trap cleanup_on_exit EXIT
trap 'log_message "INFO" "User interruption"; exit 130' INT
trap 'log_message "ERROR" "Script terminated unexpectedly"; exit 1' TERM

# Installation check
if [ ! -w "$HOME" ]; then
    log_message "ERROR" "Home directory not writable"
    exit 1
fi

# Startup logging
log_message "INFO" "Cursux v$CURSUX_VERSION started with arguments: $*"

# Execute main function
main "$@"
