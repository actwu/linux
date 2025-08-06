#!/bin/bash

set -e

# --- Settings ---
WALLPAPER_URL="https://github.com/vinceliuice/WhiteSur-wallpapers/blob/main/Wallpaper-nord/WhiteSur-nord-dark.png"
GTK_THEME_REPO="https://github.com/vinceliuice/WhiteSur-gtk-theme.git"
ICON_THEME_REPO="https://github.com/vinceliuice/WhiteSur-icon-theme.git"
OS_NAME="NaiOS"

# --- Ensure Dependencies ---
command -v gext >/dev/null || { echo "gext not found. Please run install_gext.sh first."; exit 1; }
command -v git >/dev/null || { echo "git not found."; exit 1; }

# --- Theme Installation ---
echo "[+] Installing WhiteSur GTK theme..."
git clone --depth=1 "$GTK_THEME_REPO" /tmp/WhiteSur-gtk-theme
cd /tmp/WhiteSur-gtk-theme
./install.sh -n NaiSur -l
cd ~

echo "[+] Installing WhiteSur icon theme..."
git clone --depth=1 "$ICON_THEME_REPO" /tmp/WhiteSur-icon-theme
cd /tmp/WhiteSur-icon-theme
./install.sh -a
cd ~

# --- Set Wallpaper ---
echo "[+] Setting wallpaper..."
mkdir -p ~/Pictures/Wallpapers
wget -q "$WALLPAPER_URL" -O ~/Pictures/Wallpapers/naimacos.jpg
gsettings set org.gnome.desktop.background picture-uri "file://$HOME/Pictures/Wallpapers/naimacos.jpg"

# --- Install Extensions with gext ---
echo "[+] Installing recommended GNOME extensions..."
gext install dash-to-dock@micxgx.gmail.com
gext install ding@rastersoft.com
gext install user-theme@gnome-shell-extensions.gcampax.github.com
gext enable dash-to-dock@micxgx.gmail.com
gext enable ding@rastersoft.com
gext enable user-theme@gnome-shell-extensions.gcampax.github.com

# --- Apply Theme & Icons ---
echo "[+] Applying theme and icons..."
gsettings set org.gnome.desktop.interface gtk-theme "NaiSur"
gsettings set org.gnome.desktop.wm.preferences theme "NaiSur"
gsettings set org.gnome.desktop.interface icon-theme "WhiteSur"

# --- Change OS Name to NaiOS ---
echo "[+] Setting OS name to NaiOS..."
if [[ $EUID -ne 0 ]]; then
echo "  [!] Changing OS name requires sudo privileges."
sudo bash -c "echo 'PRETTY_NAME=\"$OS_NAME\"' > /etc/os-release"
else
echo 'PRETTY_NAME="'"$OS_NAME"'"' > /etc/os-release
fi

# --- Done ---
echo -e "\n🎉 Your GNOME desktop is now transformed into NaiOS (macOS-style)!"
