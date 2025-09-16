#!/data/data/com.termux/files/usr/bin/bash
# === Northern Terpz Official Build Info ===
VERSION="1.0.0-beta"
BUILD_TYPE="Official Northern Terpz Build"

# This hash is generated from the official release file
OFFICIAL_HASH="4b967e3c9495c2da9b491a57307cb6d5"

# Calculate current file hash (excluding the OFFICIAL_HASH line itself)
CURRENT_HASH=$(grep -v OFFICIAL_HASH "$0" | md5sum | awk '{print $1}')

clear
echo -e "\e[1;32mNorthern Terpz — sessionkiller v$VERSION\e[0m"
echo -e "\e[1;36m$BUILD_TYPE\e[0m"
echo

# Warn if hash doesn't match official
if [ "$CURRENT_HASH" != "$OFFICIAL_HASH" ]; then
    echo -e "\e[1;31mWARNING: This is NOT an official Northern Terpz build.\e[0m"
    echo "Functionality may differ from the official release."
    echo
fi
# Big pixel skull
echo -e "
 ███████████████████████████
███████▀▀▀░░░░░░░▀▀▀███████
████▀░░░░░░░░░░░░░░░░░▀████
███│░░░░░░░░░░░░░░░░░░░│███
██▌│░░░░░░░░░░░░░░░░░░░│▐██
██░└┐░░░░░░░░░░░░░░░░░┌┘░██
██░░└┐░░░░░░░░░░░░░░░┌┘░░██
██░░┌┘▄▄▄▄▄░░░░░▄▄▄▄▄└┐░░██
██▌░│██████▌░░░▐██████│░▐██
███░│▐███▀▀░░▄░░▀▀███▌│░███
██▀─┘░░░░░░░▐█▌░░░░░░░└─▀██
██▄░░░▄▄▄▓░░▀█▀░░▓▄▄▄░░░▄██
████▄─┘██▌░░░░░░░▐██└─▄████
█████░░▐█─┬┬┬┬┬┬┬─█▌░░█████
████▌░░░▀┬┼┼┼┼┼┼┼┬▀░░░▐████
█████▄░░░└┴┴┴┴┴┴┴┘░░░▄█████
███████▄░░░░░░░░░░░▄███████
██████████▄▄▄▄▄▄▄██████████
███████████████████████████
"

# Stylised title
echo -e "\n🆂🅴🆂🆂🅸🅾🅽 🅺🅸🅻🅻🅴🆁 🆅1\n"
#===================================================
set -u

TAG_FILE="$HOME/.session_tags"
COLOUR_FILE="$HOME/.session_tag_colours"
LOG_FILE="$HOME/.killsession.log"
SESSION_LIST="$HOME/.session_list.txt"
CURRENT_TTY=$(tty | awk -F/ '{print $NF}')
CPU_ALERT=50.0
MEM_ALERT=20.0

touch "$TAG_FILE" "$COLOUR_FILE" "$LOG_FILE" "$SESSION_LIST"

# Colours
CYAN="\033[1;36m"; WHITE="\033[1;37m"; BLUE="\033[1;34m"
GREEN="\033[1;32m"; YELLOW="\033[1;33m"; RED="\033[1;31m"
MAGENTA="\033[1;35m"; BOLDRED="\033[1;91m"; RESET="\033[0m"

prompt() { echo -e "${CYAN}$1${RESET}"; }
success() { echo -e "${GREEN}$1${RESET}"; }
warn() { echo -e "${YELLOW}$1${RESET}"; }
error() { echo -e "${BOLDRED}$1${RESET}"; }
log_action() { echo "$(date '+%F %T') | $1" >> "$LOG_FILE"; }

# --- List sessions ---
list_sessions() {
    top -bn1 | awk 'NR>7 {print $1, $9, $10}' > "$HOME/.cpu_mem.tmp"
    : > "$SESSION_LIST"
    ps -A | awk -v cur="$CURRENT_TTY" \
        -v tagfile="$TAG_FILE" -v cpumemfile="$HOME/.cpu_mem.tmp" \
        -v cpu_alert="$CPU_ALERT" -v mem_alert="$MEM_ALERT" '
    BEGIN {
        while ((getline line < cpumemfile) > 0) {
            split(line, parts, " ")
            cpumap[parts[1]]=parts[2]
            memmap[parts[1]]=parts[3]
        }
        close(cpumemfile)
        count=0
    }
    NR>1 && $2 ~ /^pts/ {
        count++
        pid=$1
        tty=$2
        cmd=$4
        for (i=5; i<=NF; i++) cmd=cmd" "$i
        cpu_val = (pid in cpumap) ? cpumap[pid] : "0.0"
        mem_val = (pid in memmap) ? memmap[pid] : "0.0"
        printf "%-3s %-8s %-8s %-6s %-6s %s\n",
            count, pid, tty, cpu_val, mem_val, cmd
        printf "%-3s %-8s %-8s %-6s %-6s %s\n",
            count, pid, tty, cpu_val, mem_val, cmd >> "'"$SESSION_LIST"'"
    }'
}

# --- Kill sessions ---
kill_sessions() {
    for choice in "$@"; do
        PID=$(awk -v num="$choice" 'NR==num {print $2}' "$SESSION_LIST")
        TTY=$(awk -v num="$choice" 'NR==num {print $3}' "$SESSION_LIST")
        CPU=$(awk -v num="$choice" 'NR==num {print $4}' "$SESSION_LIST")
        MEM=$(awk -v num="$choice" 'NR==num {print $5}' "$SESSION_LIST")
        CMD=$(awk -v num="$choice" 'NR==num {for (i=6; i<=NF; i++) printf $i" "; print ""}' "$SESSION_LIST")
        if [ -n "${PID:-}" ]; then
            if [ "${TTY:-}" = "$CURRENT_TTY" ]; then
                warn "Skipping current session ($TTY)"
            else
                prompt "About to kill:
  PID: $PID
  TTY: ${TTY:-unknown}
  CMD: ${CMD:-unknown}
  CPU: ${CPU:-?}%
  MEM: ${MEM:-?}%"
                read -p "$(echo -e ${CYAN}Confirm kill? [y/N]:${RESET} )" -r confirm
                if [[ "${confirm:-}" =~ ^[Yy]$ ]]; then
                    kill -15 "$PID" 2>/dev/null || true
                    sleep 1
                    if kill -0 "$PID" 2>/dev/null; then
                        kill -9 "$PID" 2>/dev/null || true
                    fi
                    success "Killed PID $PID (${TTY:-?})"
                    log_action "Killed PID $PID (TTY=${TTY:-?}) CMD=${CMD:-?} CPU=${CPU:-?} MEM=${MEM:-?}"
                else
                    warn "Skipped."
                fi
            fi
        else
            error "Invalid choice: $choice"
        fi
    done
}

# --- Suspend sessions ---
suspend_sessions() {
    for choice in "$@"; do
        PID=$(awk -v num="$choice" 'NR==num {print $2}' "$SESSION_LIST")
        TTY=$(awk -v num="$choice" 'NR==num {print $3}' "$SESSION_LIST")
        CPU=$(awk -v num="$choice" 'NR==num {print $4}' "$SESSION_LIST")
        MEM=$(awk -v num="$choice" 'NR==num {print $5}' "$SESSION_LIST")
        CMD=$(awk -v num="$choice" 'NR==num {for (i=6; i<=NF; i++) printf $i" "; print ""}' "$SESSION_LIST")
        if [ -n "${PID:-}" ]; then
            kill -STOP "$PID" 2>/dev/null || true
            success "Suspended PID $PID (${TTY:-?})"
            log_action "Suspended PID $PID (TTY=${TTY:-?}) CMD=${CMD:-?} CPU=${CPU:-?} MEM=${MEM:-?}"
        else
            error "Invalid choice: $choice"
        fi
    done
}

# --- Resume sessions ---
resume_sessions() {
    for choice in "$@"; do
        PID=$(awk -v num="$choice" 'NR==num {print $2}' "$SESSION_LIST")
        TTY=$(awk -v num="$choice" 'NR==num {print $3}' "$SESSION_LIST")
        CPU=$(awk -v num="$choice" 'NR==num {print $4}' "$SESSION_LIST")
        MEM=$(awk -v num="$choice" 'NR==num {print $5}' "$SESSION_LIST")
        CMD=$(awk -v num="$choice" 'NR==num {for (i=6; i<=NF; i++) printf $i" "; print ""}' "$SESSION_LIST")
        if [ -n "${PID:-}" ]; then
            kill -CONT "$PID" 2>/dev/null || true
            success "Resumed PID $PID (${TTY:-?})"
            log_action "Resumed PID $PID (TTY=${TTY:-?}) CMD=${CMD:-?} CPU=${CPU:-?} MEM=${MEM:-?}"
        else
            error "Invalid choice: $choice"
        fi
    done
}

# --- Main menu loop ---
while true; do
    clear
    echo "Active Termux sessions (CPU% / MEM%):"
    echo "--------------------------------------"
    list_sessions
    echo "--------------------------------------"
    prompt "Enter number(s) to kill, 't' to tag, 's' to suspend, 'r' to resume, 'c' to colour, or 'q' to quit:"
    read -r action
    case "$action" in
        t)
            prompt "Enter menu number to tag:"
            read -r tnum
            TTY=$(awk -v num="$tnum" 'NR==num {print $3}' "$SESSION_LIST")
            if [ -n "${TTY:-}" ]; then
                prompt "Enter tag for $TTY:"
                read -r newtag
                grep -v "^$TTY:" "$TAG_FILE" > "$TAG_FILE.tmp" 2>/dev/null || true
                echo "$TTY:$newtag" >> "$TAG_FILE.tmp"
                mv "$TAG_FILE.tmp" "$TAG_FILE"
                success "Tag saved."
                log_action "Tagged $TTY as '$newtag'"
            else
                error "Invalid choice."
            fi
            ;;
        c)
            if ! [ -s "$TAG_FILE" ]; then
                warn "No tags found. Tag a session first with 't'."
            else
                prompt "Available tags:"
                cut -d: -f2 "$TAG_FILE" | sed '/^[[:space:]]*$/d' | sort -u | nl -w2 -s'. '
                read -p "$(echo -e ${CYAN}Enter tag number to recolour:${RESET} )" -r tnum
                TAG=$(cut -d: -f2 "$TAG_FILE" | sed '/^[[:space:]]*$/d' | sort -u | sed -n "${tnum}p")
                if [ -z "${TAG:-}" ]; then
                    error "Invalid choice."
                else
                    prompt "Choose a new colour for '$TAG':"
                    echo -e "1) ${RED}Red${RESET}"
                    echo -e "2) ${GREEN}Green${RESET}"
                    echo -e "3) ${YELLOW}Yellow${RESET}"
                    echo -e "4) ${BLUE}Blue${RESET}"
                    echo -e "5) ${MAGENTA}Magenta${RESET}"
                    echo -e "6) ${CYAN}Cyan${RESET}"
                    echo -e "7) ${WHITE}White${RESET}"
                    read -p "Enter choice: " -r colour_choice
                    case "${colour_choice:-}" in
                        1) COLOUR="$RED" ;;
                        2) COLOUR="$GREEN" ;;
                        3) COLOUR="$YELLOW" ;;
                        4) COLOUR="$BLUE" ;;
                        5) COLOUR="$MAGENTA" ;;
                        6) COLOUR="$CYAN" ;;
                        7) COLOUR="$WHITE" ;;
                        *) error "Invalid colour choice." ; continue ;;
                    esac
                    grep -v "^$TAG:" "$COLOUR_FILE" > "$COLOUR_FILE.tmp" 2>/dev/null || true
                    echo "$TAG:$COLOUR" >> "$COLOUR_FILE.tmp"
                    mv "$COLOUR_FILE.tmp" "$COLOUR_FILE"
                    success "Colour for '$TAG' updated."
                fi
            fi
            ;;
        k)
            prompt "Enter session numbers to kill (space separated):"
            read -r nums
            kill_sessions $nums
            ;;
        s)
            prompt "Enter session numbers to suspend:"
            read -r nums
            suspend_sessions $nums
            ;;
        r)
            prompt "Enter session numbers to resume:"
            read -r nums
            resume_sessions $nums
            ;;
        q)
            exit 0
            ;;
        *)
            error "Invalid choice."
            ;;
    esac
    read -p "Press Enter to continue..." dummy
echo
echo -e "\e[1;33m[sessionkiller]\e[0m Exiting — returning to Termux console..."
sleep 0.5
done
