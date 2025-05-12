#!/usr/bin/env bash

# Some usage notes:
# ./macspoof.sh spoof - Spoof to a new randomized MAC address
# ./macspoof.sh unspoof - Restore original MAC address
# ./macspoof.sh history - View logs of macspoof.sh (this program)

# === Configuration ===
LOG_DIR="$HOME/.macspoof/log"
MAC_STORE="$HOME/.macspoof/real_mac"

# === Setup ===
mkdir -p "$LOG_DIR"
echo "Log directory: $LOG_DIR"

# === Functions ===

get_interface() {
	# Auto-detect active Wi-Fi interface on macOS
	networksetup -listallhardwareports |     awk '/Wi-Fi|AirPort/{getline; print $2; exit}'
}

get_current_mac() {
	ifconfig "$INTERFACE" | awk '/ether/ {print $2}'
}

generate_random_mac() {
	openssl rand -hex 6 | sed 's/\(..\)/\1:/g' | cut -c1-17
}

# generate_smart_mac() attempts to create a MAC address that looks like
# it belongs to your computer's actual vendor. The reason for doing this
# is to try and trick enterprise-grade networks (like airports or
# airlines) that perform OUI validation (validating a given MAC address
# against a connecting-client's hardware vendor)
generate_smart_mac() {
	local current_mac
	current_mac=$(get_current_mac)

	if [[ "$current_mac" =~ ^([[:xdigit:]]{2}:){5}[[:xdigit:]]{2}$ ]]; then
		local oui suffix
		oui=$(echo "$current_mac" | cut -d':' -f1-3)
		suffix=$(openssl rand -hex 3 | sed 's/\\(..\\)/\\1:/g' | cut -c1-8)
		echo "$oui:$suffix"
	else
		# Fall back if invalid or undetectable
		generate_random_mac
	fi
}

log_action() {
	local action="$1"
	local mac="$2"
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] $action → $mac" >> "$LOG_DIR/history.log"
}

spoof_mac() {
	if [ ! -f "$MAC_STORE" ]; then
		REAL_MAC=$(get_current_mac)
		echo "$REAL_MAC" > "$MAC_STORE"
		echo "Stored original MAC: $REAL_MAC"
	else
		echo "Original MAC already stored at $MAC_STORE"
	fi

	NEW_MAC=$(generate_smart_mac)
	echo "Spoofing MAC to: $NEW_MAC"

	sudo ifconfig "$INTERFACE" down
	sudo ifconfig "$INTERFACE" ether "$NEW_MAC"
	sudo ifconfig "$INTERFACE" up

	log_action "spoofed" "$NEW_MAC"
	echo "✅ MAC address spoofed to $NEW_MAC"
}

unspoof_mac() {
	if [ -f "$MAC_STORE" ]; then
		REAL_MAC=$(cat "$MAC_STORE")
		echo "Unspoofing... Restoring MAC to: $REAL_MAC"

		sudo ifconfig "$INTERFACE" down
		sudo ifconfig "$INTERFACE" ether "$REAL_MAC"
		sudo ifconfig "$INTERFACE" up

		rm "$MAC_STORE"
		log_action "unspoofed" "$REAL_MAC"
		echo "✅ MAC address unspoofed."
	else
		echo "❌ No stored MAC found. Cannot unspoof."
	fi
}

# === Main ===

INTERFACE=$(get_interface)

if [ -z "$INTERFACE" ]; then
	echo "❌ Could not detect a Wi-Fi interface."
	exit 1
fi

case "$1" in
	spoof)
		spoof_mac
		;;
	unspoof)
		unspoof_mac
		;;
	history)
		if [ -f "$LOG_DIR/history.log" ]; then
			cat "$LOG_DIR/history.log" | less
		else
			echo "No spoof history found."
		fi
		;;
	*)
		echo "Usage: $0 [spoof|unspoof|history]"
		exit 1
		;;
esac
