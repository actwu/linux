#!/bin/bash

# Required packages
packages="git gnome-shell-extensions gnome-tweak-tool"

# Optional gext installation
install_gext() {
    if command -v gext >/dev/null 2>&1; then
        echo "gext already installed."
        return 0
    fi

    echo "Trying to install 'gext' (GNOME Extensions CLI)..."

    if command -v pipx >/dev/null 2>&1; then
        pipx install gnome-extensions-cli && return 0
    elif command -v pip3 >/dev/null 2>&1; then
        pip3 install --user gnome-extensions-cli && return 0
    fi

    echo "Failed to install 'gext'. You can install it manually via pipx or pip3."
    return 1
}

install_with() {
    cmd=$1
    install_cmd=$2

    if command -v "$cmd" >/dev/null 2>&1; then
        echo "Installing using $cmd..."
        if eval "$install_cmd"; then
            echo "Packages installed successfully using $cmd."
            return 0
        else
            echo "Failed to install using $cmd."
        fi
    fi
    return 1
}

# Try each package manager
install_with apt     "sudo apt update && sudo apt install -y $packages"     ||
install_with dnf     "sudo dnf install -y $packages"                       ||
install_with pacman  "sudo pacman -Syu --noconfirm $packages"             ||
install_with pamac   "sudo pamac install -y $packages"                    ||
install_with zypper  "sudo zypper install -y $packages"                   ||
{
    echo "No supported package manager found or all failed."
    exit 1
}

# Try to install gext
install_gext
