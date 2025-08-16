#!/usr/bin/env bash
# 随机IP生成器 v2 / DNS IP生成器 v2

# Colors
if [ -t 1 ]; then
  C_GREEN='\033[32m'; C_RED='\033[31m'; C_CYAN='\033[36m'; C_YELLOW='\033[33m'; C_RESET='\033[0m'
else
  C_GREEN=''; C_RED=''; C_CYAN=''; C_YELLOW=''; C_RESET=''
fi

# Trap Ctrl+C
trap 'echo -e "\n${C_YELLOW}[!] 已停止${C_RESET}"; exit 1' INT

# Random IPv4
rand_ipv4() {
  printf "%d.%d.%d.%d" $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256))
}

# Random IPv6
rand_ipv6() {
  local out=""
  for i in {1..8}; do
    local h
    h=$(printf "%04x" $((RANDOM % 65536)))
    out+="$h"
    [ "$i" -lt 8 ] && out+=":"
  done
  printf "%s" "$out"
}

# Country lookup (needs internet)
get_country() {
  local ip="$1"
  local country
  country=$(curl -s "https://ipinfo.io/${ip}/country")
  [ -z "$country" ] && country="未知"   # Chinese for Unknown
  echo "$country"
}

# Spinner symbols
spin_frames=('⣾' '⣽' '⣻' '⢿' '⡿' '⣟' '⣯' '⣷')
spinner() {
  local i=$((RANDOM % ${#spin_frames[@]}))
  printf "%s" "${spin_frames[$i]}"
}

# --- Main ---
echo -e "${C_CYAN}========================================${C_RESET}"
echo -e "${C_CYAN}        随机IP生成器 v2                ${C_RESET}"
echo -e "${C_CYAN}========================================${C_RESET}"

echo
echo "1) IPv4"
echo "2) IPv6"
read -r -p "Select IP version [1/2]: " MODE
[ -z "$MODE" ] && MODE="1"

read -r -p "How many IPs to generate? [300]: " COUNT
COUNT=${COUNT:-300}

echo
echo "[*] Generating $COUNT random IP addresses..."
echo

IPS=()

if [ "$MODE" = "1" ]; then
  for ((i=1; i<=COUNT; i++)); do
    ip=$(rand_ipv4)
    spin=$(spinner)
    echo -e "${C_CYAN}${spin} 生成IPv4 -> ${ip}${C_RESET}"
    IPS+=("$ip")
    sleep 0.02
  done
else
  for ((i=1; i<=COUNT; i++)); do
    ip=$(rand_ipv6)
    spin=$(spinner)
    echo -e "${C_CYAN}${spin} 生成IPv6 -> ${ip}${C_RESET}"
    IPS+=("$ip")
    sleep 0.02
  done
fi

# --- Final 5 addresses ---
clear   # Clean screen before showing results
echo -e "${C_GREEN}========== 最终结果 (Final Results) ==========${C_RESET}"
echo

for i in {1..5}; do
  idx=$((RANDOM % COUNT))
  sel=${IPS[$idx]}
  country=$(get_country "$sel")
  echo -e "${C_GREEN}$i) $sel  ->  $country${C_RESET}"
done

echo
echo -e "${C_YELLOW}完成 (Done).${C_RESET}"
