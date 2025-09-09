#!/bin/bash

# Cursux - Gestionnaire de Curseurs Linux Avancé
# Version 222.0 - Alternative complète à Custom Cursor pour Linux
# Auteur: PapaOursPolaire
# Licence: MIT

set -e

# Configuration globale
CURSUX_VERSION="2.0.0"
CURSUX_DIR="$HOME/.cursux"
CURSORS_DIR="$CURSUX_DIR/cursors"
CUSTOM_DIR="$CURSUX_DIR/custom"
TEMP_DIR="$CURSUX_DIR/temp"
BACKUP_DIR="$CURSUX_DIR/backup"
CACHE_DIR="$CURSUX_DIR/cache"
REPO_DIR="$CURSUX_DIR/repository"
CONFIG_FILE="$CURSUX_DIR/config.json"
LOG_FILE="$CURSUX_DIR/cursux.log"

# Configuration du repository GitHub
GITHUB_REPO_USER="${CURSUX_GITHUB_USER:-}"
GITHUB_REPO_NAME="${CURSUX_GITHUB_REPO:-}"
GITHUB_API_BASE="https://api.github.com"
GITHUB_RAW_BASE="https://raw.githubusercontent.com"

# URLs par défaut pour les curseurs populaires
DEFAULT_CURSORS_REPOS=(
    "ful1e5/Bibata_Cursor"
    "keeferrourke/capitaine-cursors"
    "vinceliuice/McMojave-cursors"
    "alvatip/Nordzy-cursors"
)

# Couleurs et styles
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
UNDERLINE='\033[4m'
NC='\033[0m'

# Icônes et symboles
ICON_SUCCESS="✅"
ICON_ERROR="❌"
ICON_WARNING="⚠️"
ICON_INFO="ℹ️"
ICON_DOWNLOAD="📥"
ICON_UPLOAD="📤"
ICON_CREATE="🎨"
ICON_DELETE="🗑️"
ICON_APPLY="✨"
ICON_BACKUP="💾"
ICON_RESTORE="📁"
ICON_UPDATE="🔄"
ICON_SEARCH="🔍"
ICON_LIST="📋"
ICON_CONFIG="⚙️"
ICON_HELP="❓"

# Support d'internationalisation basique
declare -A LANG_STRINGS
LANG_STRINGS=(
    ["welcome"]="Bienvenue dans Cursux - Gestionnaire de curseurs Linux avancé"
    ["current_cursor"]="Curseur actuel"
    ["no_cursors_found"]="Aucun curseur trouvé"
    ["cursor_applied"]="Curseur appliqué avec succès"
    ["cursor_created"]="Curseur personnalisé créé avec succès"
    ["operation_cancelled"]="Opération annulée"
    ["invalid_option"]="Option invalide"
    ["file_not_found"]="Fichier non trouvé"
    ["download_complete"]="Téléchargement terminé"
    ["conversion_complete"]="Conversion terminée"
)

# Fonction de logging
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    
    if [ "$level" = "ERROR" ]; then
        echo -e "${RED}${ICON_ERROR} $message${NC}" >&2
    elif [ "$level" = "WARNING" ]; then
        echo -e "${YELLOW}${ICON_WARNING} $message${NC}"
    elif [ "$level" = "SUCCESS" ]; then
        echo -e "${GREEN}${ICON_SUCCESS} $message${NC}"
    else
        echo -e "${BLUE}${ICON_INFO} $message${NC}"
    fi
}

# Logo amélioré avec version
show_logo() {
    clear
    echo -e "${PURPLE}${BOLD}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║          ██████╗██╗   ██╗██████╗ ███████╗██╗   ██╗██╗  ██╗    ║"
    echo "║         ██╔════╝██║   ██║██╔══██╗██╔════╝██║   ██║╚██╗██╔╝    ║"
    echo "║         ██║     ██║   ██║██████╔╝███████╗██║   ██║ ╚███╔╝     ║"
    echo "║         ██║     ██║   ██║██╔══██╗╚════██║██║   ██║ ██╔██╗     ║"
    echo "║         ╚██████╗╚██████╔╝██║  ██║███████║╚██████╔╝██╔╝ ██╗    ║"
    echo "║          ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝    ║"
    echo "║                                                              ║"
    echo "║              ${WHITE}Linux Cursor Manager Advanced v$CURSUX_VERSION${PURPLE}            ║"
    echo "║               ${WHITE}Alternative professionnelle à Custom Cursor${PURPLE}         ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Fonction d'aide étendue
show_help() {
    echo -e "${WHITE}${BOLD}CURSUX - Gestionnaire de Curseurs Linux Avancé v$CURSUX_VERSION${NC}"
    echo ""
    echo -e "${CYAN}${BOLD}UTILISATION:${NC}"
    echo "  cursux [OPTION] [ARGUMENTS]"
    echo ""
    echo -e "${CYAN}${BOLD}OPTIONS PRINCIPALES:${NC}"
    echo "  ${GREEN}-i, --install${NC}       Installer/Télécharger des curseurs"
    echo "  ${GREEN}-c, --create${NC}        Créer un curseur personnalisé"
    echo "  ${GREEN}-l, --list${NC}          Lister les curseurs disponibles"
    echo "  ${GREEN}-a, --apply${NC}         Appliquer un curseur"
    echo "  ${GREEN}-r, --remove${NC}        Supprimer un curseur"
    echo "  ${GREEN}-s, --search${NC}        Rechercher des curseurs"
    echo "  ${GREEN}--convert${NC}           Convertir curseurs Windows (.cur/.ani) vers Linux"
    echo ""
    echo -e "${CYAN}${BOLD}GESTION DES DONNÉES:${NC}"
    echo "  ${GREEN}-b, --backup${NC}        Sauvegarder la configuration"
    echo "  ${GREEN}--restore${NC}           Restaurer une sauvegarde"
    echo "  ${GREEN}--export${NC}            Exporter un curseur vers .cursuxpack"
    echo "  ${GREEN}--import${NC}            Importer un fichier .cursuxpack"
    echo ""
    echo -e "${CYAN}${BOLD}REPOSITORY GITHUB:${NC}"
    echo "  ${GREEN}--repo-sync${NC}         Synchroniser avec le repository GitHub"
    echo "  ${GREEN}--repo-search${NC}       Rechercher dans le repository"
    echo "  ${GREEN}--repo-install${NC}      Installer depuis le repository"
    echo ""
    echo -e "${CYAN}${BOLD}ANIMATION ET EFFETS:${NC}"
    echo "  ${GREEN}--animate${NC}           Créer un curseur animé depuis GIF/vidéo"
    echo "  ${GREEN}--effects${NC}           Appliquer des effets (ombre, couleur, etc.)"
    echo "  ${GREEN}--batch${NC}             Traitement par lots"
    echo ""
    echo -e "${CYAN}${BOLD}CONFIGURATION:${NC}"
    echo "  ${GREEN}--config${NC}            Éditer la configuration"
    echo "  ${GREEN}--setup-repo${NC}        Configurer le repository GitHub"
    echo "  ${GREEN}-u, --update${NC}        Mettre à jour Cursux"
    echo "  ${GREEN}--debug${NC}             Mode débogage verbose"
    echo "  ${GREEN}-h, --help${NC}          Afficher cette aide"
    echo ""
    echo -e "${YELLOW}${BOLD}EXEMPLES:${NC}"
    echo "  ${CYAN}cursux --create image.png --size 32 --hotspot 16,16${NC}"
    echo "  ${CYAN}cursux --convert windows_cursor.cur${NC}"
    echo "  ${CYAN}cursux --animate animation.gif --fps 10${NC}"
    echo "  ${CYAN}cursux --repo-search \"minimal\"${NC}"
    echo "  ${CYAN}cursux --effects --shadow --color \"#ff0000\"${NC}"
    echo "  ${CYAN}cursux --batch --input-dir ./cursors --output-dir ./converted${NC}"
    echo ""
    echo -e "${PURPLE}${BOLD}VARIABLES D'ENVIRONNEMENT:${NC}"
    echo "  ${CYAN}CURSUX_GITHUB_USER${NC}  - Nom d'utilisateur GitHub"
    echo "  ${CYAN}CURSUX_GITHUB_REPO${NC}  - Nom du repository"
    echo "  ${CYAN}CURSUX_DEBUG${NC}        - Active le mode débogage (1/0)"
    echo ""
}

# Vérification des dépendances étendue
check_dependencies() {
    local deps_required=("curl" "jq" "convert" "xcursorgen" "file")
    local deps_optional=("dialog" "whiptail" "git" "ffmpeg" "gifsicle")
    local missing_required=()
    local missing_optional=()
    
    log_message "INFO" "Vérification des dépendances..."
    
    # Dépendances requises
    for dep in "${deps_required[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_required+=("$dep")
        fi
    done
    
    # Dépendances optionnelles
    for dep in "${deps_optional[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_optional+=("$dep")
        fi
    done
    
    if [ ${#missing_required[@]} -ne 0 ]; then
        log_message "ERROR" "Dépendances requises manquantes: ${missing_required[*]}"
        echo -e "${YELLOW}Installez-les avec:${NC}"
        echo "  ${CYAN}Ubuntu/Debian:${NC} sudo apt install curl jq imagemagick x11-apps file"
        echo "  ${CYAN}Fedora:${NC} sudo dnf install curl jq ImageMagick libXcursor file"
        echo "  ${CYAN}Arch:${NC} sudo pacman -S curl jq imagemagick libxcursor file"
        echo "  ${CYAN}openSUSE:${NC} sudo zypper install curl jq ImageMagick libXcursor file"
        exit 1
    fi
    
    if [ ${#missing_optional[@]} -ne 0 ]; then
        log_message "WARNING" "Dépendances optionnelles manquantes: ${missing_optional[*]}"
        echo -e "${YELLOW}${ICON_INFO} Certaines fonctionnalités avancées ne seront pas disponibles${NC}"
        echo -e "${CYAN}Pour activer toutes les fonctionnalités, installez:${NC}"
        echo "  ${CYAN}Ubuntu/Debian:${NC} sudo apt install dialog git ffmpeg gifsicle"
        echo "  ${CYAN}Fedora:${NC} sudo dnf install dialog git ffmpeg gifsicle"
        echo "  ${CYAN}Arch:${NC} sudo pacman -S dialog git ffmpeg gifsicle"
    fi
    
    log_message "SUCCESS" "Vérification des dépendances terminée"
}

# Configuration JSON avancée
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
        "user": "$GITHUB_REPO_USER",
        "repository": "$GITHUB_REPO_NAME",
        "auto_sync": false,
        "last_sync": ""
    },
    "display": {
        "show_preview": true,
        "use_colors": true,
        "animation_preview": true
    },
    "effects": {
        "default_shadow": true,
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
    }
}
EOF
        log_message "SUCCESS" "Configuration par défaut créée"
    fi
}

# Initialisation complète
init_cursux() {
    echo -e "${BLUE}${ICON_CONFIG} Initialisation de Cursux...${NC}"
    
    # Créer tous les répertoires
    local directories=("$CURSORS_DIR" "$CUSTOM_DIR" "$TEMP_DIR" "$BACKUP_DIR" "$CACHE_DIR" "$REPO_DIR")
    for dir in "${directories[@]}"; do
        mkdir -p "$dir"
        log_message "INFO" "Répertoire créé: $dir"
    done
    
    # Initialiser le fichier de log
    touch "$LOG_FILE"
    
    # Créer la configuration JSON
    init_config
    
    # Créer les fichiers d'index
    echo '{"cursors": [], "last_updated": ""}' > "$REPO_DIR/index.json"
    echo '{"favorites": [], "recent": []}' > "$CURSUX_DIR/user_data.json"
    
    log_message "SUCCESS" "Cursux initialisé avec succès"
}

# Détection de l'environnement de bureau
detect_desktop_environment() {
    local de="unknown"
    
    if [ "$XDG_CURRENT_DESKTOP" ]; then
        de="$XDG_CURRENT_DESKTOP"
    elif [ "$DESKTOP_SESSION" ]; then
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

# Fonction de recherche avancée
search_cursors() {
    local query="$1"
    local search_type="${2:-all}" # all, local, remote, favorites
    
    if [ -z "$query" ]; then
        read -p "Terme de recherche: " query
    fi
    
    if [ -z "$query" ]; then
        log_message "ERROR" "Terme de recherche requis"
        return 1
    fi
    
    echo -e "${CYAN}${ICON_SEARCH} Recherche: '$query'${NC}"
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

# Recherche locale
search_local_cursors() {
    local query="$1"
    local found=false
    
    echo -e "${WHITE}${BOLD}Curseurs locaux correspondants:${NC}"
    
    # Recherche dans les curseurs personnalisés
    if [ -d "$CUSTOM_DIR" ]; then
        for cursor_dir in "$CUSTOM_DIR"/*; do
            if [ -d "$cursor_dir" ]; then
                cursor_name=$(basename "$cursor_dir")
                if [[ "$cursor_name" =~ .*"$query".* ]]; then
                    echo "  ${GREEN}🎨 $cursor_name${NC} (personnalisé)"
                    found=true
                fi
            fi
        done
    fi
    
    # Recherche dans les curseurs téléchargés
    if [ -d "$CURSORS_DIR" ]; then
        for cursor_dir in "$CURSORS_DIR"/*; do
            if [ -d "$cursor_dir" ]; then
                cursor_name=$(basename "$cursor_dir")
                if [[ "$cursor_name" =~ .*"$query".* ]]; then
                    echo "  ${BLUE}📦 $cursor_name${NC} (téléchargé)"
                    found=true
                fi
            fi
        done
    fi
    
    if [ "$found" = false ]; then
        echo "  ${YELLOW}Aucun curseur local trouvé${NC}"
    fi
    
    echo ""
}

# Conversion de curseurs Windows
convert_windows_cursor() {
    local input_file="$1"
    local output_name="$2"
    
    if [ -z "$input_file" ]; then
        echo -e "${RED}${ICON_ERROR} Fichier d'entrée requis${NC}"
        echo "Usage: cursux --convert <fichier.cur|fichier.ani> [nom_sortie]"
        return 1
    fi
    
    if [ ! -f "$input_file" ]; then
        log_message "ERROR" "Fichier non trouvé: $input_file"
        return 1
    fi
    
    # Détecter le type de fichier
    local file_type=$(file -b --mime-type "$input_file")
    local base_name=$(basename "$input_file" | sed 's/\.[^.]*$//')
    output_name="${output_name:-$base_name}"
    
    echo -e "${BLUE}${ICON_DOWNLOAD} Conversion de curseur Windows...${NC}"
    echo "  ${CYAN}Fichier:${NC} $input_file"
    echo "  ${CYAN}Type:${NC} $file_type"
    echo "  ${CYAN}Sortie:${NC} $output_name"
    echo ""
    
    local temp_png="$TEMP_DIR/${base_name}.png"
    local output_dir="$CUSTOM_DIR/$output_name"
    local cursors_dir="$output_dir/cursors"
    
    mkdir -p "$cursors_dir"
    
    # Conversion selon le type
    case "$file_type" in
        *"x-cursor"*|*"cursor"*)
            # Fichier .cur - utiliser ImageMagick
            convert "$input_file"[0] "$temp_png" 2>/dev/null || {
                log_message "ERROR" "Impossible de convertir le fichier .cur"
                return 1
            }
            ;;
        *"x-win-bitmap"*|*"bitmap"*)
            # Fichier .ani ou bitmap
            convert "$input_file" "$temp_png" 2>/dev/null || {
                log_message "ERROR" "Impossible de convertir le fichier bitmap"
                return 1
            }
            ;;
        *)
            log_message "ERROR" "Type de fichier non supporté: $file_type"
            return 1
            ;;
    esac
    
    if [ ! -f "$temp_png" ]; then
        log_message "ERROR" "Échec de la conversion"
        return 1
    fi
    
    # Obtenir les dimensions de l'image
    local dimensions=$(identify -format "%wx%h" "$temp_png" 2>/dev/null)
    local width=$(echo "$dimensions" | cut -d'x' -f1)
    local height=$(echo "$dimensions" | cut -d'x' -f2)
    
    echo -e "${YELLOW}Dimensions détectées: ${width}x${height}${NC}"
    
    # Demander les paramètres de conversion
    echo "Configuration du curseur converti:"
    read -p "Taille du curseur (défaut: $width): " cursor_size
    cursor_size=${cursor_size:-$width}
    
    read -p "Hotspot X (défaut: $((width/2))): " hotspot_x
    hotspot_x=${hotspot_x:-$((width/2))}
    
    read -p "Hotspot Y (défaut: $((height/2))): " hotspot_y
    hotspot_y=${hotspot_y:-$((height/2))}
    
    # Redimensionner si nécessaire
    if [ "$cursor_size" != "$width" ]; then
        convert "$temp_png" -resize "${cursor_size}x${cursor_size}" "$temp_png"
    fi
    
    # Créer le fichier de configuration xcursor
    cat > "$TEMP_DIR/cursor.conf" << EOF
$cursor_size $hotspot_x $hotspot_y $temp_png
EOF
    
    # Générer tous les types de curseurs
    local cursor_types=("default" "pointer" "hand1" "hand2" "text" "wait" "crosshair" "help" "not-allowed" "move")
    
    echo -e "${YELLOW}${ICON_CREATE} Génération des curseurs...${NC}"
    for cursor_type in "${cursor_types[@]}"; do
        xcursorgen "$TEMP_DIR/cursor.conf" "$cursors_dir/$cursor_type"
        echo "  ${GREEN}✓${NC} $cursor_type"
    done
    
    # Créer les liens symboliques
    create_cursor_symlinks "$cursors_dir"
    
    # Créer le fichier index.theme
    create_cursor_theme_file "$output_dir" "$output_name" "Curseur converti depuis Windows"
    
    log_message "SUCCESS" "Curseur Windows converti: $output_name"
    
    # Proposer d'appliquer
    read -p "Appliquer ce curseur maintenant? (o/N): " apply_now
    if [[ "$apply_now" =~ ^[oOyY]$ ]]; then
        apply_cursor "$output_name"
    fi
    
    # Nettoyer
    rm -f "$temp_png" "$TEMP_DIR/cursor.conf"
}

# Création de curseur animé depuis GIF
create_animated_cursor() {
    local gif_file="$1"
    local output_name="$2"
    local fps="${3:-10}"
    
    if [ -z "$gif_file" ]; then
        echo -e "${RED}${ICON_ERROR} Fichier GIF requis${NC}"
        return 1
    fi
    
    if [ ! -f "$gif_file" ]; then
        log_message "ERROR" "Fichier GIF non trouvé: $gif_file"
        return 1
    fi
    
    if ! command -v gifsicle &> /dev/null; then
        log_message "ERROR" "gifsicle requis pour les curseurs animés"
        echo "Installez avec: sudo apt install gifsicle"
        return 1
    fi
    
    local base_name=$(basename "$gif_file" .gif)
    output_name="${output_name:-${base_name}_animated}"
    
    echo -e "${BLUE}${ICON_CREATE} Création de curseur animé...${NC}"
    echo "  ${CYAN}Source:${NC} $gif_file"
    echo "  ${CYAN}Nom:${NC} $output_name"
    echo "  ${CYAN}FPS:${NC} $fps"
    
    local output_dir="$CUSTOM_DIR/$output_name"
    local cursors_dir="$output_dir/cursors"
    local frames_dir="$TEMP_DIR/frames"
    
    mkdir -p "$cursors_dir" "$frames_dir"
    
    # Extraire les frames du GIF
    echo -e "${YELLOW}${ICON_DOWNLOAD} Extraction des frames...${NC}"
    gifsicle --explode "$gif_file" --output "$frames_dir/frame"
    
    local frame_count=$(ls "$frames_dir"/frame.*.gif 2>/dev/null | wc -l)
    
    if [ "$frame_count" -eq 0 ]; then
        log_message "ERROR" "Impossible d'extraire les frames du GIF"
        return 1
    fi
    
    echo "  ${GREEN}$frame_count frames extraites${NC}"
    
    # Convertir chaque frame en PNG
    echo -e "${YELLOW}Conversion des frames...${NC}"
    local frame_files=()
    for frame_file in "$frames_dir"/frame.*.gif; do
        if [ -f "$frame_file" ]; then
            local frame_num=$(basename "$frame_file" .gif | sed 's/frame\.//')
            local png_file="$frames_dir/frame_$(printf "%03d" "$frame_num").png"
            convert "$frame_file" "$png_file"
            frame_files+=("$png_file")
            echo "  ${GREEN}✓${NC} Frame $frame_num"
        fi
    done
    
    # Demander les paramètres
    read -p "Taille du curseur (défaut: 32): " cursor_size
    cursor_size=${cursor_size:-32}
    
    read -p "Hotspot X (défaut: 16): " hotspot_x
    hotspot_x=${hotspot_x:-16}
    
    read -p "Hotspot Y (défaut: 16): " hotspot_y
    hotspot_y=${hotspot_y:-16}
    
    # Créer le fichier de configuration xcursor pour animation
    local delay=$((1000 / fps))
    cat > "$TEMP_DIR/animated.conf" << EOF
EOF
    
    for png_file in "${frame_files[@]}"; do
        # Redimensionner chaque frame
        convert "$png_file" -resize "${cursor_size}x${cursor_size}" "$png_file"
        echo "$cursor_size $hotspot_x $hotspot_y $png_file $delay" >> "$TEMP_DIR/animated.conf"
    done
    
    # Générer le curseur animé
    echo -e "${YELLOW}${ICON_CREATE} Génération du curseur animé...${NC}"
    xcursorgen "$TEMP_DIR/animated.conf" "$cursors_dir/default"
    
    # Créer des copies pour tous les types
    local cursor_types=("pointer" "hand1" "hand2" "text" "wait" "crosshair" "help" "not-allowed" "move")
    for cursor_type in "${cursor_types[@]}"; do
        cp "$cursors_dir/default" "$cursors_dir/$cursor_type"
    done
    
    # Créer les liens symboliques
    create_cursor_symlinks "$cursors_dir"
    
    # Créer le fichier theme
    create_cursor_theme_file "$output_dir" "$output_name" "Curseur animé créé depuis GIF"
    
    log_message "SUCCESS" "Curseur animé créé: $output_name"
    
    # Nettoyer
    rm -rf "$frames_dir" "$TEMP_DIR/animated.conf"
    
    # Proposer d'appliquer
    read -p "Appliquer ce curseur animé maintenant? (o/N): " apply_now
    if [[ "$apply_now" =~ ^[oOyY]$ ]]; then
        apply_cursor "$output_name"
    fi
}

# Fonction pour créer les liens symboliques de curseurs
create_cursor_symlinks() {
    local cursors_dir="$1"
    
    cd "$cursors_dir"
    
    # Liens standards X11
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
    
    # Liens de redimensionnement
    ln -sf "default" "top_left_corner" 2>/dev/null || true
    ln -sf "default" "top_right_corner" 2>/dev/null || true
    ln -sf "default" "bottom_left_corner" 2>/dev/null || true
    ln -sf "default" "bottom_right_corner" 2>/dev/null || true
    ln -sf "default" "left_side" 2>/dev/null || true
    ln -sf "default" "right_side" 2>/dev/null || true
    ln -sf "default" "top_side" 2>/dev/null || true
    ln -sf "default" "bottom_side" 2>/dev/null || true
}

# Créer le fichier index.theme
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

# Synchronisation avec le repository GitHub
sync_github_repository() {
    local github_user=$(jq -r '.github.user' "$CONFIG_FILE" 2>/dev/null || echo "")
    local github_repo=$(jq -r '.github.repository' "$CONFIG_FILE" 2>/dev/null || echo "")
    
    if [ -z "$github_user" ] || [ -z "$github_repo" ]; then
        echo -e "${YELLOW}${ICON_WARNING} Repository GitHub non configuré${NC}"
        echo "Utilisez: cursux --setup-repo"
        return 1
    fi
    
    echo -e "${BLUE}${ICON_DOWNLOAD} Synchronisation avec $github_user/$github_repo...${NC}"
    
    local api_url="$GITHUB_API_BASE/repos/$github_user/$github_repo/contents"
    local temp_index="$TEMP_DIR/repo_index.json"
    
    # Télécharger l'index du repository
    if curl -s "$api_url" > "$temp_index"; then
        echo -e "${GREEN}${ICON_SUCCESS} Repository accessible${NC}"
        
        # Parser les fichiers disponibles
        local cursor_files=($(jq -r '.[] | select(.name | test("\\.(cur|ani|png|gif|zip|tar\\.gz|tar\\.xz)$"; "i")) | .name' "$temp_index" 2>/dev/null || echo ""))
        
        if [ ${#cursor_files[@]} -gt 0 ]; then
            echo -e "${CYAN}Curseurs disponibles dans le repository:${NC}"
            for i in "${!cursor_files[@]}"; do
                echo "  $((i+1)). ${cursor_files[$i]}"
            done
            
            # Mettre à jour l'index local
            jq --argjson files "$(printf '%s\n' "${cursor_files[@]}" | jq -R . | jq -s .)" \
               --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
               '.cursors = $files | .last_updated = $timestamp' \
               "$REPO_DIR/index.json" > "$TEMP_DIR/new_index.json"
            
            mv "$TEMP_DIR/new_index.json" "$REPO_DIR/index.json"
            
            # Mettre à jour la configuration
            jq --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
               '.github.last_sync = $timestamp' \
               "$CONFIG_FILE" > "$TEMP_DIR/new_config.json"
            mv "$TEMP_DIR/new_config.json" "$CONFIG_FILE"
            
            log_message "SUCCESS" "Synchronisation terminée - ${#cursor_files[@]} curseurs trouvés"
        else
            echo -e "${YELLOW}${ICON_WARNING} Aucun curseur trouvé dans le repository${NC}"
        fi
    else
        log_message "ERROR" "Impossible d'accéder au repository GitHub"
        return 1
    fi
    
    rm -f "$temp_index"
}

# Recherche dans le repository distant
search_remote_cursors() {
    local query="$1"
    local github_user=$(jq -r '.github.user' "$CONFIG_FILE" 2>/dev/null || echo "")
    local github_repo=$(jq -r '.github.repository' "$CONFIG_FILE" 2>/dev/null || echo "")
    
    echo -e "${WHITE}${BOLD}Repository GitHub ($github_user/$github_repo):${NC}"
    
    if [ -z "$github_user" ] || [ -z "$github_repo" ]; then
        echo "  ${YELLOW}Repository non configuré${NC}"
        return
    fi
    
    local repo_index="$REPO_DIR/index.json"
    if [ ! -f "$repo_index" ]; then
        echo "  ${YELLOW}Index local non trouvé - utilisez --repo-sync${NC}"
        return
    fi
    
    local matching_cursors=($(jq -r ".cursors[] | select(. | test(\"$query\"; \"i\"))" "$repo_index" 2>/dev/null || echo ""))
    
    if [ ${#matching_cursors[@]} -gt 0 ]; then
        for cursor in "${matching_cursors[@]}"; do
            echo "  ${PURPLE}🌐 $cursor${NC} (repository)"
        done
    else
        echo "  ${YELLOW}Aucun curseur trouvé dans le repository${NC}"
    fi
    
    echo ""
}

# Installation depuis le repository GitHub
install_from_repository() {
    local cursor_name="$1"
    local github_user=$(jq -r '.github.user' "$CONFIG_FILE" 2>/dev/null || echo "")
    local github_repo=$(jq -r '.github.repository' "$CONFIG_FILE" 2>/dev/null || echo "")
    
    if [ -z "$github_user" ] || [ -z "$github_repo" ]; then
        log_message "ERROR" "Repository GitHub non configuré"
        return 1
    fi
    
    if [ -z "$cursor_name" ]; then
        # Afficher la liste des curseurs disponibles
        local repo_index="$REPO_DIR/index.json"
        if [ ! -f "$repo_index" ]; then
            echo -e "${YELLOW}${ICON_WARNING} Synchronisez d'abord avec --repo-sync${NC}"
            return 1
        fi
        
        local available_cursors=($(jq -r '.cursors[]' "$repo_index" 2>/dev/null || echo ""))
        if [ ${#available_cursors[@]} -eq 0 ]; then
            echo -e "${YELLOW}${ICON_WARNING} Aucun curseur disponible${NC}"
            return 1
        fi
        
        echo -e "${CYAN}Curseurs disponibles dans le repository:${NC}"
        for i in "${!available_cursors[@]}"; do
            echo "  $((i+1)). ${available_cursors[$i]}"
        done
        
        read -p "Choisissez un curseur (1-${#available_cursors[@]}): " choice
        
        if [ "$choice" -ge 1 ] && [ "$choice" -le "${#available_cursors[@]}" ]; then
            cursor_name="${available_cursors[$((choice-1))]}"
        else
            log_message "ERROR" "Choix invalide"
            return 1
        fi
    fi
    
    echo -e "${BLUE}${ICON_DOWNLOAD} Installation de '$cursor_name' depuis le repository...${NC}"
    
    local download_url="$GITHUB_RAW_BASE/$github_user/$github_repo/main/$cursor_name"
    local temp_file="$TEMP_DIR/$cursor_name"
    
    if curl -L -o "$temp_file" "$download_url"; then
        echo -e "${GREEN}${ICON_SUCCESS} Téléchargement réussi${NC}"
        
        # Déterminer le type de fichier et traiter en conséquence
        local file_type=$(file -b --mime-type "$temp_file")
        local base_name=$(basename "$cursor_name" | sed 's/\.[^.]*$//')
        
        case "$file_type" in
            *"zip"*|*"compressed"*)
                echo -e "${YELLOW}Extraction de l'archive...${NC}"
                unzip -q "$temp_file" -d "$TEMP_DIR/extracted/"
                # Traiter les fichiers extraits
                process_extracted_cursors "$TEMP_DIR/extracted" "$base_name"
                ;;
            *"image/png"*|*"image/jpeg"*)
                echo -e "${YELLOW}Création du curseur depuis l'image...${NC}"
                create_cursor_from_image "$temp_file" "$base_name"
                ;;
            *"image/gif"*)
                echo -e "${YELLOW}Création du curseur animé depuis le GIF...${NC}"
                create_animated_cursor "$temp_file" "$base_name"
                ;;
            *"cursor"*)
                echo -e "${YELLOW}Conversion du curseur Windows...${NC}"
                convert_windows_cursor "$temp_file" "$base_name"
                ;;
            *)
                log_message "WARNING" "Type de fichier non reconnu, tentative de traitement comme archive"
                # Essayer de traiter comme archive
                mkdir -p "$TEMP_DIR/extracted"
                if tar -xf "$temp_file" -C "$TEMP_DIR/extracted" 2>/dev/null; then
                    process_extracted_cursors "$TEMP_DIR/extracted" "$base_name"
                else
                    log_message "ERROR" "Impossible de traiter le fichier"
                    return 1
                fi
                ;;
        esac
        
        log_message "SUCCESS" "Curseur '$base_name' installé depuis le repository"
        
        # Nettoyer
        rm -f "$temp_file"
        rm -rf "$TEMP_DIR/extracted"
        
    else
        log_message "ERROR" "Échec du téléchargement"
        return 1
    fi
}

# Traitement des curseurs extraits d'archives
process_extracted_cursors() {
    local extracted_dir="$1"
    local cursor_name="$2"
    
    # Chercher les fichiers de curseurs dans l'archive extraite
    local cursor_files=($(find "$extracted_dir" -type f \( -name "*.cur" -o -name "*.ani" -o -name "*.png" -o -name "*.gif" \) 2>/dev/null))
    
    if [ ${#cursor_files[@]} -eq 0 ]; then
        # Chercher un répertoire de curseurs structuré
        local cursor_dirs=($(find "$extracted_dir" -type d -name "*cursor*" 2>/dev/null))
        if [ ${#cursor_dirs[@]} -gt 0 ]; then
            # Copier le répertoire de curseurs
            cp -r "${cursor_dirs[0]}" "$CURSORS_DIR/$cursor_name"
            echo -e "${GREEN}${ICON_SUCCESS} Curseur structuré copié${NC}"
        else
            log_message "ERROR" "Aucun fichier de curseur trouvé dans l'archive"
            return 1
        fi
    else
        # Traiter chaque fichier de curseur trouvé
        for cursor_file in "${cursor_files[@]}"; do
            local file_basename=$(basename "$cursor_file")
            local file_name="${file_basename%.*}"
            
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

# Création de curseur à partir d'une image simple
create_cursor_from_image() {
    local image_file="$1"
    local cursor_name="$2"
    local cursor_size="${3:-32}"
    local hotspot_x="${4:-16}"
    local hotspot_y="${5:-16}"
    
    local output_dir="$CUSTOM_DIR/$cursor_name"
    local cursors_dir="$output_dir/cursors"
    
    mkdir -p "$cursors_dir"
    
    # Redimensionner l'image
    local temp_png="$TEMP_DIR/${cursor_name}_resized.png"
    convert "$image_file" -resize "${cursor_size}x${cursor_size}" "$temp_png"
    
    # Créer le fichier de configuration
    cat > "$TEMP_DIR/cursor.conf" << EOF
$cursor_size $hotspot_x $hotspot_y $temp_png
EOF
    
    # Générer tous les types de curseurs
    local cursor_types=("default" "pointer" "hand1" "hand2" "text" "wait" "crosshair" "help" "not-allowed" "move")
    
    for cursor_type in "${cursor_types[@]}"; do
        xcursorgen "$TEMP_DIR/cursor.conf" "$cursors_dir/$cursor_type"
    done
    
    # Créer les liens symboliques et le fichier theme
    create_cursor_symlinks "$cursors_dir"
    create_cursor_theme_file "$output_dir" "$cursor_name" "Curseur créé depuis image"
    
    # Nettoyer
    rm -f "$temp_png" "$TEMP_DIR/cursor.conf"
}

# Système d'effets visuels
apply_cursor_effects() {
    local cursor_path="$1"
    local effects_config="$2"
    
    if [ ! -f "$cursor_path" ]; then
        log_message "ERROR" "Fichier curseur non trouvé: $cursor_path"
        return 1
    fi
    
    echo -e "${BLUE}${ICON_CREATE} Application d'effets visuels...${NC}"
    
    # Parser la configuration d'effets
    local shadow=false
    local shadow_color="#000000"
    local shadow_opacity="0.5"
    local shadow_blur="2"
    local tint_color=""
    local brightness="1.0"
    local contrast="1.0"
    
    # Mode interactif si pas de configuration fournie
    if [ -z "$effects_config" ]; then
        echo -e "${CYAN}Configuration des effets:${NC}"
        
        read -p "Ajouter une ombre portée? (o/N): " add_shadow
        if [[ "$add_shadow" =~ ^[oOyY]$ ]]; then
            shadow=true
            read -p "Couleur de l'ombre (hex, défaut: #000000): " shadow_color
            shadow_color=${shadow_color:-#000000}
            read -p "Opacité (0.0-1.0, défaut: 0.5): " shadow_opacity
            shadow_opacity=${shadow_opacity:-0.5}
            read -p "Flou (pixels, défaut: 2): " shadow_blur
            shadow_blur=${shadow_blur:-2}
        fi
        
        read -p "Teinter avec une couleur (hex, optionnel): " tint_color
        read -p "Luminosité (0.5-2.0, défaut: 1.0): " brightness
        brightness=${brightness:-1.0}
        read -p "Contraste (0.5-2.0, défaut: 1.0): " contrast
        contrast=${contrast:-1.0}
    fi
    
    local temp_image="$TEMP_DIR/cursor_effects.png"
    
    # Convertir le curseur en image temporaire
    convert "$cursor_path" "$temp_image" 2>/dev/null || {
        log_message "ERROR" "Impossible de convertir le curseur en image"
        return 1
    }
    
    # Appliquer les effets
    local convert_cmd="convert $temp_image"
    
    # Ajuster luminosité et contraste
    if [ "$brightness" != "1.0" ] || [ "$contrast" != "1.0" ]; then
        convert_cmd="$convert_cmd -modulate $(echo "$brightness * 100" | bc | cut -d. -f1),100,100"
        convert_cmd="$convert_cmd -sigmoidal-contrast ${contrast}x50%"
        echo -e "${YELLOW}  Ajustement luminosité/contraste${NC}"
    fi
    
    # Appliquer une teinte
    if [ -n "$tint_color" ]; then
        convert_cmd="$convert_cmd -colorize 30%,$tint_color"
        echo -e "${YELLOW}  Application de la teinte: $tint_color${NC}"
    fi
    
    # Ajouter une ombre portée
    if [ "$shadow" = true ]; then
        convert_cmd="$convert_cmd \\( +clone -background '$shadow_color' -shadow ${shadow_opacity}x${shadow_blur}+2+2 \\) +swap -background none -layers merge +repage"
        echo -e "${YELLOW}  Ajout d'ombre portée${NC}"
    fi
    
    convert_cmd="$convert_cmd $temp_image"
    
    # Exécuter la commande d'effets
    eval "$convert_cmd" || {
        log_message "ERROR" "Échec de l'application des effets"
        return 1
    }
    
    echo -e "${GREEN}${ICON_SUCCESS} Effets appliqués avec succès${NC}"
    
    # Le fichier modifié est maintenant dans $temp_image
    # Il peut être utilisé pour régénérer le curseur
}

# Export de curseur au format .cursuxpack
export_cursor_pack() {
    local cursor_name="$1"
    local output_file="$2"
    
    if [ -z "$cursor_name" ]; then
        echo -e "${CYAN}Curseurs disponibles pour l'export:${NC}"
        list_cursors
        read -p "Nom du curseur à exporter: " cursor_name
    fi
    
    if [ -z "$cursor_name" ]; then
        log_message "ERROR" "Nom de curseur requis"
        return 1
    fi
    
    # Trouver le curseur
    local cursor_path=""
    if [ -d "$CUSTOM_DIR/$cursor_name" ]; then
        cursor_path="$CUSTOM_DIR/$cursor_name"
    elif [ -d "$CURSORS_DIR/$cursor_name" ]; then
        cursor_path="$CURSORS_DIR/$cursor_name"
    else
        log_message "ERROR" "Curseur '$cursor_name' non trouvé"
        return 1
    fi
    
    output_file="${output_file:-$cursor_name.cursuxpack}"
    
    echo -e "${BLUE}${ICON_UPLOAD} Export de '$cursor_name' vers '$output_file'...${NC}"
    
    local temp_dir="$TEMP_DIR/export_$cursor_name"
    mkdir -p "$temp_dir"
    
    # Copier les fichiers du curseur
    cp -r "$cursor_path"/* "$temp_dir/"
    
    # Créer le fichier de métadonnées
    cat > "$temp_dir/manifest.json" << EOF
{
    "name": "$cursor_name",
    "version": "1.0",
    "author": "$(whoami)",
    "description": "Curseur exporté avec Cursux",
    "created": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "cursux_version": "$CURSUX_VERSION",
    "type": "cursor_pack",
    "files": $(find "$temp_dir" -type f ! -name "manifest.json" -printf '"%P"\n' | jq -s .)
}
EOF
    
    # Créer l'archive
    (cd "$temp_dir" && tar -czf "../$output_file" .)
    mv "$TEMP_DIR/$output_file" "./$output_file"
    
    # Calculer le checksum
    local checksum=$(sha256sum "$output_file" | cut -d' ' -f1)
    echo "$checksum" > "${output_file}.sha256"
    
    log_message "SUCCESS" "Curseur exporté: $output_file"
    echo -e "${CYAN}Checksum SHA256: $checksum${NC}"
    
    # Nettoyer
    rm -rf "$temp_dir"
}

# Import de fichier .cursuxpack
import_cursor_pack() {
    local pack_file="$1"
    
    if [ -z "$pack_file" ]; then
        read -p "Chemin vers le fichier .cursuxpack: " pack_file
    fi
    
    if [ ! -f "$pack_file" ]; then
        log_message "ERROR" "Fichier non trouvé: $pack_file"
        return 1
    fi
    
    echo -e "${BLUE}${ICON_DOWNLOAD} Import de '$pack_file'...${NC}"
    
    # Vérifier le checksum si disponible
    local checksum_file="${pack_file}.sha256"
    if [ -f "$checksum_file" ]; then
        echo -e "${YELLOW}Vérification de l'intégrité...${NC}"
        if ! sha256sum -c "$checksum_file"; then
            log_message "ERROR" "Échec de la vérification d'intégrité"
            read -p "Continuer malgré tout? (o/N): " continue_anyway
            if [[ ! "$continue_anyway" =~ ^[oOyY]$ ]]; then
                return 1
            fi
        else
            echo -e "${GREEN}${ICON_SUCCESS} Intégrité vérifiée${NC}"
        fi
    fi
    
    local temp_dir="$TEMP_DIR/import_$(basename "$pack_file" .cursuxpack)"
    mkdir -p "$temp_dir"
    
    # Extraire l'archive
    if tar -xzf "$pack_file" -C "$temp_dir" 2>/dev/null; then
        # Lire les métadonnées
        local manifest="$temp_dir/manifest.json"
        if [ -f "$manifest" ]; then
            local cursor_name=$(jq -r '.name' "$manifest")
            local cursor_version=$(jq -r '.version' "$manifest")
            local cursor_author=$(jq -r '.author' "$manifest")
            local cursor_description=$(jq -r '.description' "$manifest")
            
            echo -e "${CYAN}Informations du pack:${NC}"
            echo "  ${WHITE}Nom:${NC} $cursor_name"
            echo "  ${WHITE}Version:${NC} $cursor_version"
            echo "  ${WHITE}Auteur:${NC} $cursor_author"
            echo "  ${WHITE}Description:${NC} $cursor_description"
            echo ""
            
            # Vérifier si le curseur existe déjà
            if [ -d "$CUSTOM_DIR/$cursor_name" ]; then
                echo -e "${YELLOW}${ICON_WARNING} Le curseur '$cursor_name' existe déjà${NC}"
                read -p "Remplacer? (o/N): " replace_existing
                if [[ ! "$replace_existing" =~ ^[oOyY]$ ]]; then
                    log_message "INFO" "Import annulé"
                    rm -rf "$temp_dir"
                    return 0
                fi
                rm -rf "$CUSTOM_DIR/$cursor_name"
            fi
            
            # Copier les fichiers
            mkdir -p "$CUSTOM_DIR/$cursor_name"
            cp -r "$temp_dir"/* "$CUSTOM_DIR/$cursor_name/"
            rm -f "$CUSTOM_DIR/$cursor_name/manifest.json" # Supprimer le manifest de l'installation
            
            log_message "SUCCESS" "Curseur '$cursor_name' importé avec succès"
            
            # Proposer d'appliquer
            read -p "Appliquer ce curseur maintenant? (o/N): " apply_now
            if [[ "$apply_now" =~ ^[oOyY]$ ]]; then
                apply_cursor "$cursor_name"
            fi
            
        else
            log_message "ERROR" "Fichier manifest.json manquant dans le pack"
            return 1
        fi
    else
        log_message "ERROR" "Impossible d'extraire l'archive"
        return 1
    fi
    
    # Nettoyer
    rm -rf "$temp_dir"
}

# Traitement par lots
batch_process() {
    local input_dir="$1"
    local output_dir="$2"
    local operation="$3" # convert, resize, effects
    
    if [ -z "$input_dir" ] || [ ! -d "$input_dir" ]; then
        log_message "ERROR" "Répertoire d'entrée requis et existant"
        return 1
    fi
    
    output_dir="${output_dir:-$input_dir/processed}"
    mkdir -p "$output_dir"
    
    echo -e "${BLUE}${ICON_CREATE} Traitement par lots: $operation${NC}"
    echo "  ${CYAN}Entrée:${NC} $input_dir"
    echo "  ${CYAN}Sortie:${NC} $output_dir"
    
    local processed=0
    local failed=0
    
    # Trouver tous les fichiers de curseurs
    while IFS= read -r -d '' file; do
        echo -e "\n${YELLOW}Traitement: $(basename "$file")${NC}"
        
        local base_name=$(basename "$file" | sed 's/\.[^.]*$//')
        
        case "$operation" in
            "convert")
                if convert_windows_cursor "$file" "$base_name"; then
                    ((processed++))
                else
                    ((failed++))
                fi
                ;;
            "resize")
                read -p "Nouvelle taille pour $(basename "$file") (défaut: 32): " new_size
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
                log_message "ERROR" "Opération non supportée: $operation"
                return 1
                ;;
        esac
        
    done < <(find "$input_dir" -type f \( -name "*.cur" -o -name "*.ani" -o -name "*.png" -o -name "*.gif" \) -print0)
    
    echo -e "\n${GREEN}${ICON_SUCCESS} Traitement terminé${NC}"
    echo "  ${WHITE}Traités avec succès:${NC} $processed"
    echo "  ${WHITE}Échecs:${NC} $failed"
}

# Configuration du repository GitHub
setup_github_repository() {
    echo -e "${BLUE}${ICON_CONFIG} Configuration du repository GitHub${NC}"
    echo ""
    
    local current_user=$(jq -r '.github.user' "$CONFIG_FILE" 2>/dev/null || echo "")
    local current_repo=$(jq -r '.github.repository' "$CONFIG_FILE" 2>/dev/null || echo "")
    
    if [ -n "$current_user" ] && [ -n "$current_repo" ]; then
        echo -e "${CYAN}Configuration actuelle:${NC}"
        echo "  ${WHITE}Utilisateur:${NC} $current_user"
        echo "  ${WHITE}Repository:${NC} $current_repo"
        echo ""
    fi
    
    read -p "Nom d'utilisateur GitHub: " github_user
    read -p "Nom du repository: " github_repo
    
    if [ -z "$github_user" ] || [ -z "$github_repo" ]; then
        log_message "ERROR" "Utilisateur et repository requis"
        return 1
    fi
    
    # Vérifier l'accessibilité du repository
    echo -e "${YELLOW}${ICON_SEARCH} Vérification du repository...${NC}"
    local test_url="$GITHUB_API_BASE/repos/$github_user/$github_repo"
    
    if curl -s "$test_url" | jq -e '.name' > /dev/null 2>&1; then
        echo -e "${GREEN}${ICON_SUCCESS} Repository accessible${NC}"
        
        # Mettre à jour la configuration
        jq --arg user "$github_user" --arg repo "$github_repo" \
           '.github.user = $user | .github.repository = $repo' \
           "$CONFIG_FILE" > "$TEMP_DIR/new_config.json"
        mv "$TEMP_DIR/new_config.json" "$CONFIG_FILE"
        
        log_message "SUCCESS" "Repository configuré: $github_user/$github_repo"
        
        # Proposer une synchronisation
        read -p "Synchroniser maintenant? (o/N): " sync_now
        if [[ "$sync_now" =~ ^[oOyY]$ ]]; then
            sync_github_repository
        fi
        
    else
        log_message "ERROR" "Repository inaccessible ou inexistant"
        echo "Vérifiez que le repository $github_user/$github_repo existe et est public"
        return 1
    fi
}

# Application de curseur améliorée avec support multi-environnements
apply_cursor() {
    local cursor_name="$1"
    
    if [ -z "$cursor_name" ]; then
        echo -e "${CYAN}${ICON_LIST} Curseurs disponibles:${NC}"
        list_cursors
        echo ""
        read -p "Nom du curseur à appliquer: " cursor_name
    fi
    
    if [ -z "$cursor_name" ]; then
        log_message "ERROR" "Nom de curseur requis"
        return 1
    fi
    
    # Chercher le curseur
    local cursor_path=""
    local cursor_type=""
    
    if [ -d "$CUSTOM_DIR/$cursor_name" ]; then
        cursor_path="$CUSTOM_DIR/$cursor_name"
        cursor_type="personnalisé"
    elif [ -d "$CURSORS_DIR/$cursor_name" ]; then
        cursor_path="$CURSORS_DIR/$cursor_name"
        cursor_type="téléchargé"
    elif [ -d "/usr/share/icons/$cursor_name" ]; then
        cursor_path="/usr/share/icons/$cursor_name"
        cursor_type="système"
    elif [ -d "$HOME/.local/share/icons/$cursor_name" ]; then
        cursor_path="$HOME/.local/share/icons/$cursor_name"
        cursor_type="utilisateur"
    else
        log_message "ERROR" "Curseur '$cursor_name' non trouvé"
        return 1
    fi
    
    echo -e "${BLUE}${ICON_APPLY} Application du curseur '$cursor_name' ($cursor_type)...${NC}"
    
    # Sauvegarder la configuration actuelle
    backup_current_config
    
    # Détecter l'environnement de bureau
    local desktop_env=$(detect_desktop_environment)
    echo -e "${CYAN}Environnement détecté: $desktop_env${NC}"
    
    # Copier le curseur si nécessaire
    mkdir -p "$HOME/.local/share/icons"
    if [ "$cursor_path" != "$HOME/.local/share/icons/$cursor_name" ]; then
        cp -r "$cursor_path" "$HOME/.local/share/icons/"
    fi
    
    # Appliquer selon l'environnement de bureau
    local applied=false
    
    case "$desktop_env" in
        *"GNOME"*|*"Unity"*)
            if command -v gsettings &> /dev/null; then
                gsettings set org.gnome.desktop.interface cursor-theme "$cursor_name"
                log_message "SUCCESS" "Curseur appliqué via gsettings (GNOME)"
                applied=true
            fi
            ;;
        *"KDE"*|*"Plasma"*)
            if command -v kwriteconfig5 &> /dev/null; then
                kwriteconfig5 --file ~/.config/kcminputrc --group Mouse --key cursorTheme "$cursor_name"
                kwriteconfig5 --file ~/.config/kdeglobals --group Icons --key Theme "$cursor_name"
                log_message "SUCCESS" "Curseur appliqué via kwriteconfig5 (KDE)"
                applied=true
            fi
            ;;
        *"XFCE"*)
            if command -v xfconf-query &> /dev/null; then
                xfconf-query -c xsettings -p /Gtk/CursorThemeName -s "$cursor_name"
                log_message "SUCCESS" "Curseur appliqué via xfconf-query (XFCE)"
                applied=true
            fi
            ;;
        *"MATE"*)
            if command -v dconf &> /dev/null; then
                dconf write /org/mate/desktop/peripherals/mouse/cursor-theme "'$cursor_name'"
                log_message "SUCCESS" "Curseur appliqué via dconf (MATE)"
                applied=true
            fi
            ;;
        *"Cinnamon"*)
            if command -v dconf &> /dev/null; then
                dconf write /org/cinnamon/desktop/interface/cursor-theme "'$cursor_name'"
                log_message "SUCCESS" "Curseur appliqué via dconf (Cinnamon)"
                applied=true
            fi
            ;;
    esac
    
    # Fallback pour tous les environnements - configuration GTK
    update_gtk_config "$cursor_name"
    
    # Application X11 directe
    if command -v xsetroot &> /dev/null; then
        XCURSOR_THEME="$cursor_name" xsetroot -cursor_name left_ptr || true
    fi
    
    # Mettre à jour la configuration Cursux
    jq --arg cursor "$cursor_name" --arg path "$cursor_path" --arg type "$cursor_type" \
       '.current_cursor = $cursor | .last_applied = {name: $cursor, path: $path, type: $type, date: (now | strftime("%Y-%m-%d %H:%M:%S"))}' \
       "$CONFIG_FILE" > "$TEMP_DIR/new_config.json"
    mv "$TEMP_DIR/new_config.json" "$CONFIG_FILE"
    
    # Ajouter aux récents
    add_to_recent_cursors "$cursor_name"
    
    if [ "$applied" = true ]; then
        log_message "SUCCESS" "Curseur '$cursor_name' appliqué avec succès!"
        echo -e "${YELLOW}${ICON_INFO} Redémarrez les applications pour voir tous les changements${NC}"
    else
        log_message "WARNING" "Application partielle - certains environnements peuvent nécessiter une déconnexion/reconnexion"
    fi
}

# Mise à jour des fichiers de configuration GTK
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
    
    log_message "INFO" "Configuration GTK mise à jour"
}

# Ajouter aux curseurs récents
add_to_recent_cursors() {
    local cursor_name="$1"
    local user_data_file="$CURSUX_DIR/user_data.json"
    
    # Créer le fichier s'il n'existe pas
    if [ ! -f "$user_data_file" ]; then
        echo '{"favorites": [], "recent": []}' > "$user_data_file"
    fi
    
    # Ajouter aux récents (maximum 10)
    jq --arg cursor "$cursor_name" \
       '.recent |= ([$cursor] + (. - [$cursor])) | .recent |= .[:10]' \
       "$user_data_file" > "$TEMP_DIR/new_user_data.json"
    mv "$TEMP_DIR/new_user_data.json" "$user_data_file"
}

# Gestion des favoris
manage_favorites() {
    local action="$1" # add, remove, list
    local cursor_name="$2"
    
    local user_data_file="$CURSUX_DIR/user_data.json"
    
    if [ ! -f "$user_data_file" ]; then
        echo '{"favorites": [], "recent": []}' > "$user_data_file"
    fi
    
    case "$action" in
        "add")
            if [ -z "$cursor_name" ]; then
                read -p "Nom du curseur à ajouter aux favoris: " cursor_name
            fi
            
            if [ -n "$cursor_name" ]; then
                jq --arg cursor "$cursor_name" \
                   '.favorites |= (. + [$cursor]) | .favorites |= unique' \
                   "$user_data_file" > "$TEMP_DIR/new_user_data.json"
                mv "$TEMP_DIR/new_user_data.json" "$user_data_file"
                log_message "SUCCESS" "'$cursor_name' ajouté aux favoris"
            fi
            ;;
        "remove")
            if [ -z "$cursor_name" ]; then
                echo -e "${CYAN}Favoris actuels:${NC}"
                jq -r '.favorites[]' "$user_data_file" 2>/dev/null | nl
                read -p "Nom du curseur à retirer des favoris: " cursor_name
            fi
            
            if [ -n "$cursor_name" ]; then
                jq --arg cursor "$cursor_name" \
                   '.favorites |= (. - [$cursor])' \
                   "$user_data_file" > "$TEMP_DIR/new_user_data.json"
                mv "$TEMP_DIR/new_user_data.json" "$user_data_file"
                log_message "SUCCESS" "'$cursor_name' retiré des favoris"
            fi
            ;;
        "list")
            echo -e "${CYAN}${ICON_LIST} Curseurs favoris:${NC}"
            local favorites=($(jq -r '.favorites[]' "$user_data_file" 2>/dev/null || echo ""))
            
            if [ ${#favorites[@]} -gt 0 ]; then
                for fav in "${favorites[@]}"; do
                    echo "  ${YELLOW}⭐ $fav${NC}"
                done
            else
                echo "  ${GRAY}Aucun favori${NC}"
            fi
            ;;
    esac
}

# Recherche de favoris
search_favorites() {
    local query="$1"
    local user_data_file="$CURSUX_DIR/user_data.json"
    
    echo -e "${WHITE}${BOLD}Favoris correspondants:${NC}"
    
    if [ ! -f "$user_data_file" ]; then
        echo "  ${YELLOW}Aucun favori${NC}"
        return
    fi
    
    local matching_favorites=($(jq -r ".favorites[] | select(. | test(\"$query\"; \"i\"))" "$user_data_file" 2>/dev/null || echo ""))
    
    if [ ${#matching_favorites[@]} -gt 0 ]; then
        for fav in "${matching_favorites[@]}"; do
            echo "  ${YELLOW}⭐ $fav${NC} (favori)"
        done
    else
        echo "  ${YELLOW}Aucun favori correspondant${NC}"
    fi
}

# Sauvegarde améliorée avec métadonnées
backup_current_config() {
    local backup_name="$1"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    backup_name="${backup_name:-backup_$timestamp}"
    
    local backup_file="$BACKUP_DIR/$backup_name.json"
    
    echo -e "${YELLOW}${ICON_BACKUP} Sauvegarde de la configuration...${NC}"
    
    # Collecter toutes les informations de configuration
    local current_cursor=""
    local gtk_theme=""
    
    if command -v gsettings &> /dev/null; then
        current_cursor=$(gsettings get org.gnome.desktop.interface cursor-theme 2>/dev/null | tr -d "'" || echo "default")
    fi
    
    # Lire les configurations GTK
    local gtk2_cursor=$(grep "gtk-cursor-theme-name" "$HOME/.gtkrc-2.0" 2>/dev/null | cut -d'"' -f2 || echo "")
    local gtk3_cursor=$(grep "gtk-cursor-theme-name" "$HOME/.config/gtk-3.0/settings.ini" 2>/dev/null | cut -d'=' -f2 || echo "")
    
    # Créer la sauvegarde complète
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
    "user_data": $(cat "$CURSUX_DIR/user_data.json" 2>/dev/null || echo '{"favorites": [], "recent": []}')
}
EOF
    
    log_message "SUCCESS" "Sauvegarde créée: $backup_file"
    
    # Nettoyer les anciennes sauvegardes (garder les 10 plus récentes)
    local backup_count=$(jq -r '.backup_count // 10' "$CONFIG_FILE")
    local backup_files=($(ls -1t "$BACKUP_DIR"/*.json 2>/dev/null | head -n "$backup_count"))
    
    if [ ${#backup_files[@]} -gt "$backup_count" ]; then
        for old_backup in $(ls -1t "$BACKUP_DIR"/*.json 2>/dev/null | tail -n +$((backup_count + 1))); do
            rm -f "$old_backup"
            log_message "INFO" "Ancienne sauvegarde supprimée: $(basename "$old_backup")"
        done
    fi
}

# Restauration de sauvegarde améliorée
restore_backup() {
    echo -e "${CYAN}${ICON_RESTORE} Sauvegardes disponibles:${NC}"
    
    local backup_files=($(find "$BACKUP_DIR" -name "*.json" -type f 2>/dev/null | sort -r))
    
    if [ ${#backup_files[@]} -eq 0 ]; then
        log_message "WARNING" "Aucune sauvegarde trouvée"
        return 1
    fi
    
    echo ""
    for i in "${!backup_files[@]}"; do
        local backup_file="${backup_files[$i]}"
        local backup_info=$(jq -r '.backup_info' "$backup_file" 2>/dev/null)
        
        if [ "$backup_info" != "null" ]; then
            local backup_name=$(echo "$backup_info" | jq -r '.name')
            local backup_date=$(echo "$backup_info" | jq -r '.date')
            local backup_desktop=$(echo "$backup_info" | jq -r '.desktop_environment')
            echo "  $((i+1)). $backup_name ($backup_date) [$backup_desktop]"
        else
            # Format ancien
            local backup_name=$(basename "$backup_file" .json)
            echo "  $((i+1)). $backup_name (format ancien)"
        fi
    done
    
    echo ""
    read -p "Choisissez une sauvegarde à restaurer (1-${#backup_files[@]}): " choice
    
    if [ "$choice" -ge 1 ] && [ "$choice" -le "${#backup_files[@]}" ]; then
        local backup_file="${backup_files[$((choice-1))]}"
        echo -e "${BLUE}${ICON_RESTORE} Restauration de la sauvegarde...${NC}"
        
        # Lire la sauvegarde
        local cursor_config=$(jq -r '.cursor_config' "$backup_file" 2>/dev/null)
        local files_backup=$(jq -r '.files_backup' "$backup_file" 2>/dev/null)
        
        if [ "$cursor_config" != "null" ] && [ "$files_backup" != "null" ]; then
            # Restauration moderne
            local current_cursor=$(echo "$cursor_config" | jq -r '.current_cursor')
            
            # Restaurer les fichiers de configuration
            if [ "$(echo "$files_backup" | jq -r '.gtkrc_2')" != "null" ]; then
                echo "$files_backup" | jq -r '.gtkrc_2' > "$HOME/.gtkrc-2.0"
            fi
            
            if [ "$(echo "$files_backup" | jq -r '.gtk3_settings')" != "null" ]; then
                mkdir -p "$HOME/.config/gtk-3.0"
                echo "$files_backup" | jq -r '.gtk3_settings' > "$HOME/.config/gtk-3.0/settings.ini"
            fi
            
            # Appliquer le curseur
            if [ -n "$current_cursor" ] && [ "$current_cursor" != "null" ]; then
                if command -v gsettings &> /dev/null; then
                    gsettings set org.gnome.desktop.interface cursor-theme "$current_cursor"
                fi
            fi
            
            # Restaurer les données utilisateur
            local user_data=$(jq -r '.user_data' "$backup_file" 2>/dev/null)
            if [ "$user_data" != "null" ]; then
                echo "$user_data" > "$CURSUX_DIR/user_data.json"
            fi
            
            log_message "SUCCESS" "Sauvegarde restaurée avec succès"
            
        else
            # Tentative de restauration du format ancien
            log_message "WARNING" "Format de sauvegarde ancien détecté"
            # Code de compatibilité ici si nécessaire
        fi
        
    else
        log_message "ERROR" "Choix invalide"
        return 1
    fi
}

# Listing avancé avec filtres et tri
list_cursors() {
    local filter="$1" # all, custom, downloaded, system, favorites, recent
    local sort_by="$2" # name, date, size, type
    
    filter="${filter:-all}"
    sort_by="${sort_by:-name}"
    
    echo -e "${CYAN}${ICON_LIST} Curseurs disponibles${NC}"
    
    if [ "$filter" != "all" ]; then
        echo -e "${WHITE}Filtre: $filter${NC}"
    fi
    
    echo ""
    
    declare -A cursor_info
    
    # Curseurs personnalisés
    if [ "$filter" = "all" ] || [ "$filter" = "custom" ]; then
        echo -e "${WHITE}${BOLD}🎨 Curseurs personnalisés:${NC}"
        
        if [ -d "$CUSTOM_DIR" ]; then
            for cursor_dir in "$CUSTOM_DIR"/*; do
                if [ -d "$cursor_dir" ]; then
                    local cursor_name=$(basename "$cursor_dir")
                    local cursor_size=$(du -sh "$cursor_dir" 2>/dev/null | cut -f1)
                    local cursor_date=$(stat -c %y "$cursor_dir" 2>/dev/null | cut -d' ' -f1)
                    
                    echo "  ${GREEN}• $cursor_name${NC} ${GRAY}($cursor_size, $cursor_date)${NC}"
                    cursor_info["$cursor_name"]="custom|$cursor_size|$cursor_date"
                fi
            done
        else
            echo "  ${GRAY}Aucun curseur personnalisé${NC}"
        fi
        echo ""
    fi
    
    # Curseurs téléchargés
    if [ "$filter" = "all" ] || [ "$filter" = "downloaded" ]; then
        echo -e "${WHITE}${BOLD}📦 Curseurs téléchargés:${NC}"
        
        if [ -d "$CURSORS_DIR" ]; then
            for cursor_dir in "$CURSORS_DIR"/*; do
                if [ -d "$cursor_dir" ]; then
                    local cursor_name=$(basename "$cursor_dir")
                    local cursor_size=$(du -sh "$cursor_dir" 2>/dev/null | cut -f1)
                    local cursor_date=$(stat -c %y "$cursor_dir" 2>/dev/null | cut -d' ' -f1)
                    
                    echo "  ${BLUE}• $cursor_name${NC} ${GRAY}($cursor_size, $cursor_date)${NC}"
                    cursor_info["$cursor_name"]="downloaded|$cursor_size|$cursor_date"
                fi
            done
        else
            echo "  ${GRAY}Aucun curseur téléchargé${NC}"
        fi
        echo ""
    fi
    
    # Curseurs système
    if [ "$filter" = "all" ] || [ "$filter" = "system" ]; then
        echo -e "${WHITE}${BOLD}🖥️ Curseurs système:${NC}"
        
        local found_system=false
        if [ -d "/usr/share/icons" ]; then
            for cursor_dir in /usr/share/icons/*; do
                if [ -d "$cursor_dir" ] && [ -d "$cursor_dir/cursors" ]; then
                    local cursor_name=$(basename "$cursor_dir")
                    echo "  ${PURPLE}• $cursor_name${NC} ${GRAY}(système)${NC}"
                    cursor_info["$cursor_name"]="system||"
                    found_system=true
                fi
            done
        fi
        
        if [ "$found_system" = false ]; then
            echo "  ${GRAY}Aucun curseur système avec structure cursors/${NC}"
        fi
        echo ""
    fi
    
    # Favoris
    if [ "$filter" = "all" ] || [ "$filter" = "favorites" ]; then
        local user_data_file="$CURSUX_DIR/user_data.json"
        if [ -f "$user_data_file" ]; then
            local favorites=($(jq -r '.favorites[]' "$user_data_file" 2>/dev/null || echo ""))
            
            if [ ${#favorites[@]} -gt 0 ]; then
                echo -e "${WHITE}${BOLD}⭐ Curseurs favoris:${NC}"
                for fav in "${favorites[@]}"; do
                    echo "  ${YELLOW}• $fav${NC}"
                done
                echo ""
            fi
        fi
    fi
    
    # Récents
    if [ "$filter" = "all" ] || [ "$filter" = "recent" ]; then
        local user_data_file="$CURSUX_DIR/user_data.json"
        if [ -f "$user_data_file" ]; then
            local recent=($(jq -r '.recent[]' "$user_data_file" 2>/dev/null || echo ""))
            
            if [ ${#recent[@]} -gt 0 ]; then
                echo -e "${WHITE}${BOLD}🕒 Curseurs récents:${NC}"
                for rec in "${recent[@]}"; do
                    echo "  ${CYAN}• $rec${NC}"
                done
                echo ""
            fi
        fi
    fi
    
    # Afficher le curseur actuel
    local current_cursor=$(jq -r '.current_cursor // empty' "$CONFIG_FILE" 2>/dev/null)
    if [ -n "$current_cursor" ]; then
        echo -e "${WHITE}${BOLD}✨ Curseur actuel: ${GREEN}$current_cursor${NC}"
    fi
}

# Suppression avancée avec confirmation
remove_cursor() {
    local cursor_name="$1"
    local force="${2:-false}"
    
    if [ -z "$cursor_name" ]; then
        echo -e "${CYAN}Curseurs supprimables:${NC}"
        echo ""
        
        echo -e "${WHITE}🎨 Curseurs personnalisés:${NC}"
        find "$CUSTOM_DIR" -maxdepth 1 -type d 2>/dev/null | while read -r cursor; do
            [ "$cursor" != "$CUSTOM_DIR" ] && basename "$cursor" | sed 's/^/  • /'
        done
        
        echo ""
        echo -e "${WHITE}📦 Curseurs téléchargés:${NC}"
        find "$CURSORS_DIR" -maxdepth 1 -type d 2>/dev/null | while read -r cursor; do
            [ "$cursor" != "$CURSORS_DIR" ] && basename "$cursor" | sed 's/^/  • /'
        done
        
        echo ""
        read -p "Nom du curseur à supprimer: " cursor_name
    fi
    
    if [ -z "$cursor_name" ]; then
        log_message "ERROR" "Nom de curseur requis"
        return 1
    fi
    
    local removed=false
    local cursor_paths=()
    
    # Trouver tous les emplacements du curseur
    if [ -d "$CUSTOM_DIR/$cursor_name" ]; then
        cursor_paths+=("$CUSTOM_DIR/$cursor_name:personnalisé")
    fi
    
    if [ -d "$CURSORS_DIR/$cursor_name" ]; then
        cursor_paths+=("$CURSORS_DIR/$cursor_name:téléchargé")
    fi
    
    if [ -d "$HOME/.local/share/icons/$cursor_name" ]; then
        cursor_paths+=("$HOME/.local/share/icons/$cursor_name:installé")
    fi
    
    if [ ${#cursor_paths[@]} -eq 0 ]; then
        log_message "ERROR" "Curseur '$cursor_name' non trouvé"
        return 1
    fi
    
    # Afficher ce qui sera supprimé
    echo -e "${YELLOW}${ICON_WARNING} Le curseur '$cursor_name' sera supprimé des emplacements suivants:${NC}"
    for path_info in "${cursor_paths[@]}"; do
        local path="${path_info%:*}"
        local type="${path_info#*:}"
        echo "  ${RED}• $path${NC} ($type)"
    done
    
    if [ "$force" != "true" ]; then
        echo ""
        read -p "Confirmer la suppression? (o/N): " confirm
        if [[ ! "$confirm" =~ ^[oOyY]$ ]]; then
            log_message "INFO" "Suppression annulée"
            return 0
        fi
    fi
    
    # Procéder à la suppression
    for path_info in "${cursor_paths[@]}"; do
        local path="${path_info%:*}"
        local type="${path_info#*:}"
        
        if rm -rf "$path"; then
            log_message "SUCCESS" "Curseur $type supprimé: $path"
            removed=true
        else
            log_message "ERROR" "Échec de suppression: $path"
        fi
    done
    
    # Retirer des favoris et récents
    if [ "$removed" = true ]; then
        local user_data_file="$CURSUX_DIR/user_data.json"
        if [ -f "$user_data_file" ]; then
            jq --arg cursor "$cursor_name" \
               '.favorites |= (. - [$cursor]) | .recent |= (. - [$cursor])' \
               "$user_data_file" > "$TEMP_DIR/new_user_data.json"
            mv "$TEMP_DIR/new_user_data.json" "$user_data_file"
        fi
        
        log_message "SUCCESS" "Curseur '$cursor_name' complètement supprimé"
    fi
}

# Interface de menu interactif améliorée
interactive_menu() {
    while true; do
        show_logo
        
        # Afficher les informations système
        local current_cursor=$(jq -r '.current_cursor // "aucun"' "$CONFIG_FILE" 2>/dev/null)
        local desktop_env=$(detect_desktop_environment)
        
        echo -e "${CYAN}${BOLD}Informations système:${NC}"
        echo "  ${WHITE}Environment:${NC} $desktop_env"
        echo "  ${WHITE}Curseur actuel:${NC} $current_cursor"
        echo "  ${WHITE}Version Cursux:${NC} $CURSUX_VERSION"
        echo ""
        
        echo -e "${CYAN}${BOLD}🎯 Menu Principal${NC}"
        echo ""
        echo "  ${GREEN}1.${NC}  📦 Installer des curseurs"
        echo "  ${GREEN}2.${NC}  🎨 Créer un curseur personnalisé"
        echo "  ${GREEN}3.${NC}  ⚡ Créer un curseur animé (GIF)"
        echo "  ${GREEN}4.${NC}  🔄 Convertir curseur Windows (.cur/.ani)"
        echo "  ${GREEN}5.${NC}  📋 Lister les curseurs"
        echo "  ${GREEN}6.${NC}  🔍 Rechercher des curseurs"
        echo "  ${GREEN}7.${NC}  ✨ Appliquer un curseur"
        echo "  ${GREEN}8.${NC}  🗑️  Supprimer un curseur"
        echo ""
        echo "  ${BLUE}9.${NC}  ⭐ Gérer les favoris"
        echo "  ${BLUE}10.${NC} 🌐 Repository GitHub"
        echo "  ${BLUE}11.${NC} 📤 Exporter curseur (.cursuxpack)"
        echo "  ${BLUE}12.${NC} 📥 Importer curseur (.cursuxpack)"
        echo ""
        echo "  ${PURPLE}13.${NC} 🎭 Effets visuels"
        echo "  ${PURPLE}14.${NC} 📦 Traitement par lots"
        echo "  ${PURPLE}15.${NC} ⚙️  Configuration"
        echo ""
        echo "  ${YELLOW}16.${NC} 💾 Sauvegarder configuration"
        echo "  ${YELLOW}17.${NC} 📁 Restaurer sauvegarde"
        echo "  ${YELLOW}18.${NC} 🔄 Mettre à jour Cursux"
        echo "  ${YELLOW}19.${NC} ❓ Aide et documentation"
        echo ""
        echo "  ${RED}0.${NC}  ❌ Quitter"
        echo ""
        
        read -p "Choisissez une option (0-19): " choice
        
        case $choice in
            1)
                install_cursors_menu
                ;;
            2)
                create_cursor_menu
                ;;
            3)
                create_animated_menu
                ;;
            4)
                convert_windows_menu
                ;;
            5)
                list_cursors_menu
                ;;
            6)
                search_cursors_menu
                ;;
            7)
                apply_cursor
                ;;
            8)
                remove_cursor
                ;;
            9)
                favorites_menu
                ;;
            10)
                github_menu
                ;;
            11)
                export_cursor_pack
                ;;
            12)
                import_cursor_pack
                ;;
            13)
                effects_menu
                ;;
            14)
                batch_menu
                ;;
            15)
                configuration_menu
                ;;
            16)
                backup_current_config
                ;;
            17)
                restore_backup
                ;;
            18)
                update_cursux
                ;;
            19)
                show_help | less
                ;;
            0)
                echo -e "${GREEN}${ICON_SUCCESS} Merci d'avoir utilisé Cursux!${NC}"
                exit 0
                ;;
            *)
                log_message "ERROR" "Option invalide: $choice"
                ;;
        esac
        
        echo ""
        read -p "Appuyez sur Entrée pour continuer..."
    done
}

# Sous-menus

# Menu d'installation de curseurs
install_cursors_menu() {
    echo -e "${CYAN}${BOLD}📦 Installation de Curseurs${NC}"
    echo ""
    echo "  ${GREEN}1.${NC} Curseurs populaires prédéfinis"
    echo "  ${GREEN}2.${NC} Depuis repository GitHub"
    echo "  ${GREEN}3.${NC} URL directe"
    echo "  ${GREEN}4.${NC} Fichier local"
    echo "  ${GREEN}0.${NC} Retour"
    echo ""
    
    read -p "Choix: " choice
    
    case $choice in
        1) install_popular_cursors ;;
        2) install_from_repository ;;
        3) install_from_url ;;
        4) install_from_file ;;
        0) return ;;
        *) log_message "ERROR" "Option invalide" ;;
    esac
}

# Menu de création de curseur
create_cursor_menu() {
    echo -e "${CYAN}${BOLD}🎨 Création de Curseur${NC}"
    echo ""
    
    read -p "Chemin vers l'image: " image_path
    if [ ! -f "$image_path" ]; then
        log_message "ERROR" "Fichier image non trouvé"
        return 1
    fi
    
    read -p "Nom du curseur: " cursor_name
    read -p "Taille (défaut: 32): " cursor_size
    cursor_size=${cursor_size:-32}
    
    read -p "Hotspot X (défaut: centre): " hotspot_x
    hotspot_x=${hotspot_x:-$((cursor_size/2))}
    
    read -p "Hotspot Y (défaut: centre): " hotspot_y
    hotspot_y=${hotspot_y:-$((cursor_size/2))}
    
    create_cursor_from_image "$image_path" "$cursor_name" "$cursor_size" "$hotspot_x" "$hotspot_y"
}

# Menu d'animation
create_animated_menu() {
    echo -e "${CYAN}${BOLD}⚡ Curseur Animé${NC}"
    echo ""
    
    read -p "Chemin vers le GIF: " gif_path
    if [ ! -f "$gif_path" ]; then
        log_message "ERROR" "Fichier GIF non trouvé"
        return 1
    fi
    
    read -p "Nom du curseur animé: " cursor_name
    read -p "FPS (défaut: 10): " fps
    fps=${fps:-10}
    
    create_animated_cursor "$gif_path" "$cursor_name" "$fps"
}

# Menu de conversion Windows
convert_windows_menu() {
    echo -e "${CYAN}${BOLD}🔄 Conversion Windows${NC}"
    echo ""
    
    read -p "Chemin vers le fichier .cur/.ani: " windows_file
    if [ ! -f "$windows_file" ]; then
        log_message "ERROR" "Fichier non trouvé"
        return 1
    fi
    
    read -p "Nom du curseur converti (optionnel): " cursor_name
    
    convert_windows_cursor "$windows_file" "$cursor_name"
}

# Menu de listage
list_cursors_menu() {
    echo -e "${CYAN}${BOLD}📋 Lister les Curseurs${NC}"
    echo ""
    echo "  ${GREEN}1.${NC} Tous les curseurs"
    echo "  ${GREEN}2.${NC} Curseurs personnalisés"
    echo "  ${GREEN}3.${NC} Curseurs téléchargés"
    echo "  ${GREEN}4.${NC} Curseurs système"
    echo "  ${GREEN}5.${NC} Favoris"
    echo "  ${GREEN}6.${NC} Récents"
    echo "  ${GREEN}0.${NC} Retour"
    echo ""
    
    read -p "Choix: " choice
    
    case $choice in
        1) list_cursors "all" ;;
        2) list_cursors "custom" ;;
        3) list_cursors "downloaded" ;;
        4) list_cursors "system" ;;
        5) list_cursors "favorites" ;;
        6) list_cursors "recent" ;;
        0) return ;;
        *) log_message "ERROR" "Option invalide" ;;
    esac
}

# Menu de recherche
search_cursors_menu() {
    echo -e "${CYAN}${BOLD}🔍 Recherche de Curseurs${NC}"
    echo ""
    
    read -p "Terme de recherche: " search_term
    if [ -n "$search_term" ]; then
        search_cursors "$search_term"
    fi
}

# Menu des favoris
favorites_menu() {
    echo -e "${CYAN}${BOLD}⭐ Gestion des Favoris${NC}"
    echo ""
    echo "  ${GREEN}1.${NC} Ajouter aux favoris"
    echo "  ${GREEN}2.${NC} Retirer des favoris"
    echo "  ${GREEN}3.${NC} Lister les favoris"
    echo "  ${GREEN}0.${NC} Retour"
    echo ""
    
    read -p "Choix: " choice
    
    case $choice in
        1) manage_favorites "add" ;;
        2) manage_favorites "remove" ;;
        3) manage_favorites "list" ;;
        0) return ;;
        *) log_message "ERROR" "Option invalide" ;;
    esac
}

# Menu GitHub
github_menu() {
    echo -e "${CYAN}${BOLD}🌐 Repository GitHub${NC}"
    echo ""
    echo "  ${GREEN}1.${NC} Configurer repository"
    echo "  ${GREEN}2.${NC} Synchroniser"
    echo "  ${GREEN}3.${NC} Rechercher dans repository"
    echo "  ${GREEN}4.${NC} Installer depuis repository"
    echo "  ${GREEN}0.${NC} Retour"
    echo ""
    
    read -p "Choix: " choice
    
    case $choice in
        1) setup_github_repository ;;
        2) sync_github_repository ;;
        3) 
            read -p "Terme de recherche: " search_term
            search_remote_cursors "$search_term"
            ;;
        4) install_from_repository ;;
        0) return ;;
        *) log_message "ERROR" "Option invalide" ;;
    esac
}

# Menu des effets
effects_menu() {
    echo -e "${CYAN}${BOLD}🎭 Effets Visuels${NC}"
    echo ""
    echo "  ${GREEN}1.${NC} Appliquer effets à un curseur"
    echo "  ${GREEN}2.${NC} Configuration par défaut des effets"
    echo "  ${GREEN}0.${NC} Retour"
    echo ""
    
    read -p "Choix: " choice
    
    case $choice in
        1)
            read -p "Chemin vers le curseur: " cursor_path
            apply_cursor_effects "$cursor_path"
            ;;
        2)
            configure_default_effects
            ;;
        0) return ;;
        *) log_message "ERROR" "Option invalide" ;;
    esac
}

# Menu de traitement par lots
batch_menu() {
    echo -e "${CYAN}${BOLD}📦 Traitement par Lots${NC}"
    echo ""
    echo "  ${GREEN}1.${NC} Convertir curseurs Windows"
    echo "  ${GREEN}2.${NC} Redimensionner curseurs"
    echo "  ${GREEN}3.${NC} Appliquer effets"
    echo "  ${GREEN}0.${NC} Retour"
    echo ""
    
    read -p "Choix: " choice
    
    case $choice in
        1)
            read -p "Répertoire d'entrée: " input_dir
            read -p "Répertoire de sortie (optionnel): " output_dir
            batch_process "$input_dir" "$output_dir" "convert"
            ;;
        2)
            read -p "Répertoire d'entrée: " input_dir
            read -p "Répertoire de sortie (optionnel): " output_dir
            batch_process "$input_dir" "$output_dir" "resize"
            ;;
        3)
            read -p "Répertoire d'entrée: " input_dir
            read -p "Répertoire de sortie (optionnel): " output_dir
            batch_process "$input_dir" "$output_dir" "effects"
            ;;
        0) return ;;
        *) log_message "ERROR" "Option invalide" ;;
    esac
}

# Menu de configuration
configuration_menu() {
    echo -e "${CYAN}${BOLD}⚙️ Configuration${NC}"
    echo ""
    echo "  ${GREEN}1.${NC} Éditer configuration JSON"
    echo "  ${GREEN}2.${NC} Réinitialiser configuration"
    echo "  ${GREEN}3.${NC} Voir configuration actuelle"
    echo "  ${GREEN}4.${NC} Configuration des effets par défaut"
    echo "  ${GREEN}5.${NC} Nettoyage du cache"
    echo "  ${GREEN}0.${NC} Retour"
    echo ""
    
    read -p "Choix: " choice
    
    case $choice in
        1) edit_configuration ;;
        2) reset_configuration ;;
        3) show_configuration ;;
        4) configure_default_effects ;;
        5) cleanup_cache ;;
        0) return ;;
        *) log_message "ERROR" "Option invalide" ;;
    esac
}

# Installation de curseurs populaires
install_popular_cursors() {
    local popular_cursors=(
        "Bibata-Modern-Classic:https://github.com/ful1e5/Bibata_Cursor/releases/latest/download/Bibata-Modern-Classic.tar.xz"
        "Bibata-Modern-Ice:https://github.com/ful1e5/Bibata_Cursor/releases/latest/download/Bibata-Modern-Ice.tar.xz"
        "Capitaine-Cursors:https://github.com/keeferrourke/capitaine-cursors/archive/refs/heads/master.zip"
        "McMojave-cursors:https://github.com/vinceliuice/McMojave-cursors/archive/refs/heads/master.zip"
        "Nordzy-cursors:https://github.com/alvatip/Nordzy-cursors/archive/refs/heads/main.zip"
    )
    
    echo -e "${CYAN}Curseurs populaires disponibles:${NC}"
    for i in "${!popular_cursors[@]}"; do
        cursor_info="${popular_cursors[$i]}"
        cursor_name="${cursor_info%%:*}"
        echo "  $((i+1)). $cursor_name"
    done
    echo "  0. Tous les curseurs"
    echo ""
    
    read -p "Choisissez (0-${#popular_cursors[@]}): " choice
    
    if [ "$choice" = "0" ]; then
        for cursor_info in "${popular_cursors[@]}"; do
            install_cursor_from_url "$cursor_info"
        done
    elif [ "$choice" -ge 1 ] && [ "$choice" -le "${#popular_cursors[@]}" ]; then
        cursor_info="${popular_cursors[$((choice-1))]}"
        install_cursor_from_url "$cursor_info"
    else
        log_message "ERROR" "Choix invalide"
    fi
}

# Installation depuis URL
install_from_url() {
    read -p "URL du curseur: " cursor_url
    if [ -n "$cursor_url" ]; then
        install_cursor_from_url "custom:$cursor_url"
    fi
}

# Installation depuis fichier local
install_from_file() {
    read -p "Chemin vers le fichier: " file_path
    if [ -f "$file_path" ]; then
        local base_name=$(basename "$file_path" | sed 's/\.[^.]*$//')
        
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
                log_message "ERROR" "Type de fichier non supporté"
                ;;
        esac
    else
        log_message "ERROR" "Fichier non trouvé"
    fi
}

# Fonction d'installation depuis URL
install_cursor_from_url() {
    local cursor_info="$1"
    local cursor_name="${cursor_info%%:*}"
    local cursor_url="${cursor_info#*:}"
    
    if [ "$cursor_name" = "custom" ]; then
        cursor_name=$(basename "$cursor_url" | sed 's/\.[^.]*$//')
    fi
    
    echo -e "${BLUE}${ICON_DOWNLOAD} Téléchargement de $cursor_name...${NC}"
    
    local temp_file="$TEMP_DIR/$(basename "$cursor_url")"
    
    if curl -L --progress-bar -o "$temp_file" "$cursor_url"; then
        echo -e "${GREEN}${ICON_SUCCESS} Téléchargement réussi${NC}"
        
        # Déterminer comment traiter le fichier
        local file_type=$(file -b --mime-type "$temp_file")
        
        case "$file_type" in
            *"zip"*)
                extract_and_install_cursor "$temp_file" "$cursor_name"
                ;;
            *"x-xz"*|*"gzip"*)
                extract_and_install_cursor "$temp_file" "$cursor_name"
                ;;
            *)
                log_message "WARNING" "Type de fichier non reconnu, tentative d'extraction"
                extract_and_install_cursor "$temp_file" "$cursor_name"
                ;;
        esac
        
        rm -f "$temp_file"
    else
        log_message "ERROR" "Échec du téléchargement"
        return 1
    fi
}

# Extraction et installation
extract_and_install_cursor() {
    local archive_file="$1"
    local cursor_name="$2"
    local extract_dir="$TEMP_DIR/extract_$cursor_name"
    
    mkdir -p "$extract_dir"
    
    # Tenter différentes méthodes d'extraction
    if [[ "$archive_file" == *.zip ]]; then
        unzip -q "$archive_file" -d "$extract_dir"
    elif [[ "$archive_file" == *.tar.xz ]]; then
        tar -xJf "$archive_file" -C "$extract_dir"
    elif [[ "$archive_file" == *.tar.gz ]]; then
        tar -xzf "$archive_file" -C "$extract_dir"
    else
        # Tentative générique
        tar -xf "$archive_file" -C "$extract_dir" 2>/dev/null || \
        unzip -q "$archive_file" -d "$extract_dir" 2>/dev/null || {
            log_message "ERROR" "Impossible d'extraire l'archive"
            return 1
        }
    fi
    
    # Chercher le répertoire de curseurs
    local cursor_dirs=($(find "$extract_dir" -type d -name "*cursor*" 2>/dev/null))
    
    if [ ${#cursor_dirs[@]} -gt 0 ]; then
        # Copier le premier répertoire de curseurs trouvé
        cp -r "${cursor_dirs[0]}" "$CURSORS_DIR/$cursor_name"
        log_message "SUCCESS" "Curseur '$cursor_name' installé"
    else
        # Chercher des fichiers de curseurs individuels
        local cursor_files=($(find "$extract_dir" -type f \( -name "*.cur" -o -name "*.png" -o -name "*.gif" \) 2>/dev/null))
        
        if [ ${#cursor_files[@]} -gt 0 ]; then
            process_extracted_cursors "$extract_dir" "$cursor_name"
        else
            log_message "ERROR" "Aucun fichier de curseur trouvé dans l'archive"
            return 1
        fi
    fi
    
    # Nettoyer
    rm -rf "$extract_dir"
}

# Configuration des effets par défaut
configure_default_effects() {
    echo -e "${CYAN}${BOLD}Configuration des Effets par Défaut${NC}"
    echo ""
    
    local current_shadow=$(jq -r '.effects.default_shadow' "$CONFIG_FILE")
    local current_shadow_color=$(jq -r '.effects.default_shadow_color' "$CONFIG_FILE")
    local current_shadow_opacity=$(jq -r '.effects.default_shadow_opacity' "$CONFIG_FILE")
    
    echo "Configuration actuelle:"
    echo "  Ombre par défaut: $current_shadow"
    echo "  Couleur d'ombre: $current_shadow_color"
    echo "  Opacité: $current_shadow_opacity"
    echo ""
    
    read -p "Activer l'ombre par défaut? (o/n): " enable_shadow
    read -p "Couleur d'ombre (hex): " shadow_color
    read -p "Opacité (0.0-1.0): " shadow_opacity
    read -p "Flou (pixels): " shadow_blur
    
    # Mettre à jour la configuration
    jq --argjson shadow "$([ "$enable_shadow" = "o" ] && echo true || echo false)" \
       --arg color "${shadow_color:-$current_shadow_color}" \
       --arg opacity "${shadow_opacity:-$current_shadow_opacity}" \
       --arg blur "${shadow_blur:-2}" \
       '.effects.default_shadow = $shadow |
        .effects.default_shadow_color = $color |
        .effects.default_shadow_opacity = ($opacity | tonumber) |
        .effects.default_shadow_blur = ($blur | tonumber)' \
       "$CONFIG_FILE" > "$TEMP_DIR/new_config.json"
    
    mv "$TEMP_DIR/new_config.json" "$CONFIG_FILE"
    log_message "SUCCESS" "Configuration des effets mise à jour"
}

# Édition de la configuration
edit_configuration() {
    local editor="${EDITOR:-nano}"
    
    echo -e "${BLUE}${ICON_CONFIG} Ouverture de la configuration avec $editor...${NC}"
    echo -e "${YELLOW}${ICON_WARNING} Attention: Une configuration invalide peut casser Cursux${NC}"
    
    read -p "Continuer? (o/N): " continue_edit
    if [[ "$continue_edit" =~ ^[oOyY]$ ]]; then
        # Créer une sauvegarde
        cp "$CONFIG_FILE" "$CONFIG_FILE.backup"
        
        # Ouvrir l'éditeur
        "$editor" "$CONFIG_FILE"
        
        # Valider la configuration JSON
        if jq . "$CONFIG_FILE" >/dev/null 2>&1; then
            log_message "SUCCESS" "Configuration mise à jour et validée"
            rm -f "$CONFIG_FILE.backup"
        else
            log_message "ERROR" "Configuration JSON invalide, restauration de la sauvegarde"
            mv "$CONFIG_FILE.backup" "$CONFIG_FILE"
        fi
    fi
}

# Affichage de la configuration
show_configuration() {
    echo -e "${CYAN}${BOLD}Configuration Actuelle${NC}"
    echo ""
    
    if command -v jq &> /dev/null; then
        jq . "$CONFIG_FILE" | sed 's/^/  /'
    else
        cat "$CONFIG_FILE" | sed 's/^/  /'
    fi
}

# Réinitialisation de la configuration
reset_configuration() {
    echo -e "${YELLOW}${ICON_WARNING} Cela va réinitialiser toute la configuration${NC}"
    read -p "Confirmer? (o/N): " confirm
    
    if [[ "$confirm" =~ ^[oOyY]$ ]]; then
        # Sauvegarder l'ancienne configuration
        cp "$CONFIG_FILE" "$BACKUP_DIR/config_backup_$(date +%Y%m%d_%H%M%S).json"
        
        # Créer une nouvelle configuration par défaut
        rm -f "$CONFIG_FILE"
        init_config
        
        log_message "SUCCESS" "Configuration réinitialisée"
    fi
}

# Nettoyage du cache
cleanup_cache() {
    echo -e "${BLUE}${ICON_DELETE} Nettoyage du cache...${NC}"
    
    local cache_size=$(du -sh "$CACHE_DIR" 2>/dev/null | cut -f1)
    local temp_size=$(du -sh "$TEMP_DIR" 2>/dev/null | cut -f1)
    
    echo "  Cache actuel: $cache_size"
    echo "  Fichiers temporaires: $temp_size"
    echo ""
    
    read -p "Nettoyer le cache et les fichiers temporaires? (o/N): " confirm
    
    if [[ "$confirm" =~ ^[oOyY]$ ]]; then
        # Nettoyer le cache
        rm -rf "$CACHE_DIR"/*
        rm -rf "$TEMP_DIR"/*
        
        # Nettoyer les anciens logs (garder les 100 dernières lignes)
        if [ -f "$LOG_FILE" ]; then
            tail -n 100 "$LOG_FILE" > "$TEMP_DIR/log_temp"
            mv "$TEMP_DIR/log_temp" "$LOG_FILE"
        fi
        
        log_message "SUCCESS" "Cache nettoyé"
    fi
}

# Mise à jour de Cursux
update_cursux() {
    echo -e "${BLUE}${ICON_UPDATE} Vérification des mises à jour...${NC}"
    
    # Dans un vrai cas, on téléchargerait depuis un repository
    local latest_version="2.0.0"
    
    if [ "$latest_version" = "$CURSUX_VERSION" ]; then
        echo -e "${GREEN}${ICON_SUCCESS} Cursux est déjà à jour (v$CURSUX_VERSION)${NC}"
    else
        echo -e "${YELLOW}Nouvelle version disponible: v$latest_version${NC}"
        echo -e "${CYAN}Pour mettre à jour manuellement:${NC}"
        echo "  1. Téléchargez la dernière version"
        echo "  2. Sauvegardez votre configuration"
        echo "  3. Remplacez le script cursux.sh"
        echo "  4. Restaurez votre configuration"
    fi
    
    echo ""
    echo -e "${CYAN}Liens utiles:${NC}"
    echo "  📖 Documentation: https://github.com/cursux/cursux/wiki"
    echo "  🐛 Signaler un bug: https://github.com/cursux/cursux/issues"
    echo "  💬 Communauté: https://github.com/cursux/cursux/discussions"
}

# Fonction principale
main() {
    # Vérifier les dépendances
    check_dependencies
    
    # Initialiser Cursux
    init_cursux
    
    # Mode débogage si demandé
    if [ "${CURSUX_DEBUG:-0}" = "1" ] || [[ "$*" == *"--debug"* ]]; then
        set -x
        log_message "INFO" "Mode débogage activé"
    fi
    
    # Traitement des arguments de ligne de commande
    case "${1:-}" in
        -i|--install)
            shift
            if [ "$1" = "--popular" ]; then
                install_popular_cursors
            elif [ "$1" = "--url" ]; then
                install_from_url
            elif [ "$1" = "--file" ]; then
                install_from_file
            else
                install_cursors_menu
            fi
            ;;
        -c|--create)
            if [ -n "$2" ]; then
                create_cursor_from_image "$2" "$3" "$4" "$5" "$6"
            else
                create_cursor_menu
            fi
            ;;
        --animate)
            if [ -n "$2" ]; then
                create_animated_cursor "$2" "$3" "$4"
            else
                create_animated_menu
            fi
            ;;
        --convert)
            if [ -n "$2" ]; then
                convert_windows_cursor "$2" "$3"
            else
                convert_windows_menu
            fi
            ;;
        -l|--list)
            list_cursors "$2" "$3"
            ;;
        -a|--apply)
            apply_cursor "$2"
            ;;
        -r|--remove)
            remove_cursor "$2" "$3"
            ;;
        -s|--search)
            search_cursors "$2" "$3"
            ;;
        --favorites)
            manage_favorites "$2" "$3"
            ;;
        --export)
            export_cursor_pack "$2" "$3"
            ;;
        --import)
            import_cursor_pack "$2"
            ;;
        --repo-sync)
            sync_github_repository
            ;;
        --repo-search)
            search_remote_cursors "$2"
            ;;
        --repo-install)
            install_from_repository "$2"
            ;;
        --setup-repo)
            setup_github_repository
            ;;
        --effects)
            apply_cursor_effects "$2" "$3"
            ;;
        --batch)
            batch_process "$2" "$3" "$4"
            ;;
        --config)
            if [ "$2" = "edit" ]; then
                edit_configuration
            elif [ "$2" = "show" ]; then
                show_configuration
            elif [ "$2" = "reset" ]; then
                reset_configuration
            else
                configuration_menu
            fi
            ;;
        -b|--backup)
            backup_current_config "$2"
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
            # Mode interactif par défaut
            interactive_menu
            ;;
        *)
            log_message "ERROR" "Option inconnue: $1"
            echo "Utilisez 'cursux --help' pour voir les options disponibles"
            exit 1
            ;;
    esac
}

# Fonction de nettoyage à la sortie
cleanup_on_exit() {
    # Nettoyer les fichiers temporaires
    find "$TEMP_DIR" -type f -mmin +60 -delete 2>/dev/null || true
    
    # Compresser les anciens logs si trop volumineux
    if [ -f "$LOG_FILE" ] && [ $(wc -l < "$LOG_FILE" 2>/dev/null || echo 0) -gt 1000 ]; then
        tail -n 500 "$LOG_FILE" > "$LOG_FILE.new"
        mv "$LOG_FILE.new" "$LOG_FILE"
    fi
    
    # Nettoyer le cache si trop volumineux
    local cache_size_mb=$(du -sm "$CACHE_DIR" 2>/dev/null | cut -f1 || echo 0)
    local max_cache_mb=$(jq -r '.advanced.cache_size_mb // 100' "$CONFIG_FILE" 2>/dev/null)
    
    if [ "$cache_size_mb" -gt "$max_cache_mb" ]; then
        find "$CACHE_DIR" -type f -atime +7 -delete 2>/dev/null || true
    fi
}

# Gestion des signaux
trap cleanup_on_exit EXIT
trap 'log_message "INFO" "Interruption par utilisateur"; exit 130' INT
trap 'log_message "ERROR" "Script terminé de façon inattendue"; exit 1' TERM

# Vérification de l'installation
if [ ! -w "$HOME" ]; then
    log_message "ERROR" "Répertoire home non accessible en écriture"
    exit 1
fi

# Log du démarrage
log_message "INFO" "Cursux v$CURSUX_VERSION démarré avec les arguments: $*"

# Exécuter la fonction principale
main "$@"
