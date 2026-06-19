#!/bin/bash
set -e

# --- Splash Screen ---
clear
echo -e "\e[1;34m
                                                 
                               ▄▄█▀▀██▄  ▄█▀▀▀█▄█
                             ▄██▀    ▀██▄██    ▀█
▀██▀   ▀██▀▄█▀██▄ ▀████████▄ ██▀      ▀█████▄    
  ██   ▄█ ██   ██   ██    ██ ██        ██ ▀█████▄
   ██ ▄█   ▄█████   ██    ██ ██▄      ▄██     ▀██
    ███   ██   ██   ██    ██ ▀██▄    ▄██▀█     ██
    ▄█    ▀████▀██▄████  ████▄ ▀▀████▀▀ █▀█████▀ 
  ▄█                                             
██▀                                              

\e[0m"


echo "[+] Detecting Linux Distribution and Desktop Environment..."
DISTRO_NAME=$(grep PRETTY_NAME /etc/os-release | cut -d= -f2- | tr -d '"')
echo "    Distribution: $DISTRO_NAME"
CURRENT_DE=$(echo "${XDG_CURRENT_DESKTOP:-unknown}")
echo "    Current Desktop: $CURRENT_DE"

echo "yan os installer"
sudo -v

# Function to install GNOME based on distro
install_gnome() {
case "$ID" in
ubuntu|debian|linuxmint)
sudo apt update
sudo apt install -y gnome ubuntu-gnome-desktop gdm3
sudo dpkg-reconfigure gdm3
;;
fedora|centos|rhel)
sudo dnf groupinstall -y "GNOME Desktop"
sudo systemctl enable gdm.service
;;
arch|manjaro)
sudo pacman -Syu --noconfirm gnome gnome-extra gdm
sudo systemctl enable gdm.service
;;
*)
echo "Unsupported distro $ID. Please install GNOME manually."
exit 1
;;
esac
# Set graphical target
sudo systemctl set-default graphical.target
}

# Check if GNOME is installed by checking gnome-shell presence
if ! command -v gnome-shell >/dev/null 2>&1; then
echo "[+] GNOME not detected, installing GNOME desktop environment..."
if [ -f /etc/os-release ]; then
. /etc/os-release
install_gnome
echo "[+] GNOME installed successfully."
echo "Please reboot the system and re-run this script after logging into GNOME session."
exit 0
else
echo "Cannot detect Linux distribution. Install GNOME manually."
exit 1
fi
else
echo "[+] GNOME is installed, continuing setup..."
fi

# Detect available package manager
if command -v apt >/dev/null 2>&1; then
PKG_INSTALL="sudo apt install -y"
elif command -v dnf >/dev/null 2>&1; then
PKG_INSTALL="sudo dnf install -y"
elif command -v pamac >/dev/null 2>&1; then
PKG_INSTALL="sudo pamac install -y"
elif command -v yay >/dev/null 2>&1; then
PKG_INSTALL="yay -S --noconfirm"
elif command -v pacman >/dev/null 2>&1; then
PKG_INSTALL="sudo pacman -Syu --noconfirm"
elif command -v zypper >/dev/null 2>&1; then
PKG_INSTALL="sudo zypper install -y"
else
echo "[!] No supported package manager detected."
echo "Please install Python3 and pip manually before continuing."
exit 1
fi

# Make sure Python and pip exist
if ! command -v python >/dev/null 2>&1; then
$PKG_INSTALL python python-pip python-venv || $PKG_INSTALL python python-pip
fi

# Check for pip module
if ! command -v pip >/dev/null 2>&1; then
$PKG_INSTALL python-pip || curl -sS https://bootstrap.pypa.io/get-pip.py | python
fi

# --- Virtual environment for gext ---
GEXT_ENV="$HOME/.yanos_env"
if [ ! -d "$GEXT_ENV" ]; then
python3 -m venv "$GEXT_ENV"
fi

# Activate environment
source "$GEXT_ENV/bin/activate"

# Install gext if not already installed
if ! python3 -m pip show gnome-extensions-cli >/dev/null 2>&1; then
echo "[+] Installing GEXT (gnome-extensions-cli)..."
python3 -m pip install --upgrade pip wheel
python3 -m pip install gnome-extensions-cli
fi

# Ensure gext command is linked
if ! command -v gext >/dev/null 2>&1; then
echo "[+] Linking gext binary..."
mkdir -p "$HOME/.local/bin"
ln -sf "$GEXT_ENV/bin/gext" "$HOME/.local/bin/gext"
export PATH="$HOME/.local/bin:$PATH"
fi

# --- Settings ---
WALLPAPER_URL="https://raw.githubusercontent.com/actwu/linux/refs/heads/WEBOPL/nay%20bg.jpg"
GTK_THEME_REPO="https://github.com/vinceliuice/WhiteSur-gtk-theme.git"
ICON_THEME_REPO="https://github.com/vinceliuice/WhiteSur-icon-theme.git"
OS_NAME="yanOS"

# --- Ensure Dependencies ---
for cmd in gext git wget; do
command -v $cmd >/dev/null || { echo "$cmd not found. Please install it first."; exit 1; }
done

# --- Set Wallpaper ---
echo "[+] Just the vibe..."
mkdir -p ~/Pictures/Wallpapers
wget -q "$WALLPAPER_URL" -O ~/Pictures/Wallpapers/yanmacos.png
gsettings set org.gnome.desktop.background picture-uri "file://$HOME/Pictures/Wallpapers/yanmacos.png"
gsettings set org.gnome.desktop.background picture-uri-dark "file://$HOME/Pictures/Wallpapers/yanmacos.png"


echo "[+] Aligning..."
gsettings set org.gnome.desktop.wm.preferences button-layout "close,minimize,maximize:"

# --- Change OS Name to yanOS ---
echo "[+] Setting OS name to yanOS..."
sudo bash -c "sed -i '/^PRETTY_NAME=/d' /etc/os-release && echo 'PRETTY_NAME=\"$OS_NAME\"' >> /etc/os-release"

curl -fL https://raw.githubusercontent.com/actwu/linux/refs/heads/WEBOPL/.bashrc -o ~/.bashrc
curl -fL https://raw.githubusercontent.com/actwu/linux/refs/heads/WEBOPL/.zshrc -o ~/.zshrc

echo "[+] Theming..."
rm -rf /tmp/yan-Icons /tmp/yan-solid /tmp/yan-Icons.zip /tmp/yan-solid.zip

THEME_URL="https://github.com/actwu/linux/raw/refs/heads/WEBOPL/yan-solid.zip"
ICON_URL="https://github.com/actwu/linux/raw/refs/heads/WEBOPL/yan-Icons.zip"

THEME_DIR="$HOME/.themes"
ICON_DIR="$HOME/.local/share/icons"

mkdir -p "$THEME_DIR" "$ICON_DIR"

wget -q "$THEME_URL" -O /tmp/yan-Icons.zip
unzip -o /tmp/yan-Icons.zip -d "$THEME_DIR"

wget -q "$ICON_URL" -O /tmp/yan-solid.zip
unzip -o /tmp/yan-solid.zip -d "$ICON_DIR"

echo "[+] Theming..."
THEME_NAME=$(basename "$(find "$THEME_DIR" -maxdepth 1 -type d -name "yan*" | head -n 1)")
ICON_NAME=$(basename "$(find "$ICON_DIR" -maxdepth 1 -type d -name "yan*" | head -n 1)")

if [ -n "$THEME_NAME" ]; then
gsettings set org.gnome.desktop.interface gtk-theme "$THEME_NAME"
gsettings set org.gnome.desktop.wm.preferences theme "$THEME_NAME"
fi

if [ -n "$ICON_NAME" ]; then
gsettings set org.gnome.desktop.interface icon-theme "$ICON_NAME"

# ✅ Refresh icon cache (important)
gtk-update-icon-cache "$ICON_DIR"/* 2>/dev/null
fi




echo "[+] Designing..."
for ext in dash-to-dock@micxgx.gmail.com user-theme@gnome-shell-extensions.gcampax.github.com ding@rastersoft.com; do
echo "[+] Installing extension: $ext"
gext install "$ext" || true
gext enable "$ext" || true
done

deactivate

source ~/.bashrc;
source ~/.bashrc;

if command -v pacmac >/dev/null 2>&1; then PM_INSTALL="sudo pacman -Syu "
elif command -v apt >/dev/null 2>&1; then PM_INSTALL="sudo apt install -y"
elif command -v dnf >/dev/null 2>&1; then PM_INSTALL="sudo dnf install -y"
elif command -v zypper >/dev/null 2>&1; then PM_INSTALL="sudo zypper install -y"
elif command -v emerge >/dev/null 2>&1; then PM_INSTALL="sudo emerge"
elif command -v xbps-install >/dev/null 2>&1; then PM_INSTALL="sudo xbps-install -Sy"
fi
command -v gnome-console >/dev/null 2>&1 || $PM_INSTALL gnome-console || exit 1
kgx -- bash -c 'echo -e "\e[34m █   █ ██▀ █   ▄▀▀ ▄▀▄ █▄ ▄█ ██▀
 ▀▄▀▄▀ █▄▄ █▄▄ ▀▄▄ ▀▄▀ █ ▀ █ █▄▄
 ▀█▀ ▄▀▄
  █  ▀▄▀\e[0m"; exec bash' &
