# macspoof
On-Demand MAC Address Spoofing with Safe Restore and Logging


# 🥷 macspoof

**macspoof** is a lightweight macOS command-line utility for safely and temporarily spoofing your MAC address on public networks. It includes simple commands to spoof, unspoof (restore), and view a log of your activity --- helping improve privacy, anonymity, and network hygiene.

---

## 🔧 Features

- Auto-detects your Wi-Fi interface (macOS only)
- Randomizes your MAC address with a single command
- Saves your original MAC address for easy restoration
- Logs all spoof/unspoof activity to `~/.macspoof/log/history.log`
- Minimal dependencies (uses built-in tools and `openssl`)

---

## 🧠 Usage

Run the script from your terminal:

```bash
./macspoof.sh spoof      # Spoof to a new randomized MAC address
./macspoof.sh unspoof    # Restore your original MAC address
./macspoof.sh history    # View your spoof/unspoof history log
```

---

## 📁 Files and Directories

- `~/.macspoof/real_mac`  
  Stores your real MAC address temporarily while spoofed.

- `~/.macspoof/log/history.log`  
  Stores timestamped logs of all spoof/unspoof events.

---

## ⚠️ Requirements

- macOS with `ifconfig`, `networksetup`, and `openssl` (usually installed by default)
- `sudo` access to modify network interface MAC addresses

---

## ✅ Example

```bash
$ ./macspoof.sh spoof
Log directory: /Users/you/.macspoof/log
Stored original MAC: 40:6c:8f:aa:bb:cc
Spoofing MAC to: 00:11:22:33:44:55
✅ MAC address spoofed to 00:11:22:33:44:55

$ ./macspoof.sh unspoof
Unspoofing... Restoring MAC to: 40:6c:8f:aa:bb:cc
✅ MAC address unspoofed.
```

---

## 📜 License

This project is licensed under the MIT License. See [LICENSE](./LICENSE) for details.

---

## 👤 Author

Made by [@broeneatsdinner](https://github.com/broeneatsdinner) as part of a custom privacy tooling portfolio.
