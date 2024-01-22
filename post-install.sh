#!/usr/bin/env bash

DEPENDENCIES="git qt5ct qt6ct qt5-quickcontrols2 qt5-graphicaleffects gum tar wget curl unzip kvantum"
GH="https://github.com"
SDDM_THEME="${GH}/Kangie/sddm-sugar-candy.git"
SDDM_BACKGROUND="https://w.wallhaven.cc/full/zy/wallhaven-zyvrxy.png"
ICON_PACK="${GH}/vinceliuice/Tela-circle-icon-theme.git"
CURSOR_THEME="${GH}/ful1e5/Bibata_Cursor/releases/download/v2.0.5/Bibata-Modern-Ice.tar.xz"
GTK_THEME="Catppuccin-Mocha-Standard-Lavender-Dark"
FONTS=(
    CommitMono
)


function dir_check(){
    if [[ ! -d $1 ]];then
        mkdir -p $1
    fi
}

function spinner(){
    gum spin --spinner="dot" --title="${1}" -- bash -c "${2}"
}

function success_txt(){
    echo "${1} :white_check_mark:" | gum format -t emoji
}

function welcome_msg() {
    gum style --margin "1 0" --padding "1 2" --border double --border-foreground '#f38ba8' "$(gum style --foreground '#b4befe' 'Arch Linux Post Installation')"
    gum format  --  "# This script installs" "1. SDDM Theme" "2. GTK-3.0 & GTK-4.0 Theme" "3. Mouse Cursor Theme" "4. Icon Pack" "5. Nerd Fonts" "6. Kvantum Theme" "7. Volta.sh"
}

# Downloads sddm-sugar-candy and replaces default background 
# with chosen one
function sddm_theme(){
    spinner "Downloading sddm-sugar-candy" "git clone $SDDM_THEME /tmp/sddm-sugar-candy"
    cd /tmp/sddm-sugar-candy/Backgrounds
    rm Mountain.jpg
    spinner "Downloading background image" "curl $SDDM_BACKGROUND -o Mountain.jpg"
    sudo cp -R  /tmp/sddm-sugar-candy  /usr/share/sddm/themes/
    echo "[Theme]
    Current=sddm-sugar-candy" | sudo tee -a /etc/sddm.conf.d/sddm.conf
    success_txt "SDDM Theme Installed"
}

# Downloads tele-circle-icon pack and run it's own install script
function icon_pack(){
    spinner "Downloading icon pack" "git clone $ICON_PACK /tmp/icon-pack/"
    cd /tmp/icon-pack
    bash install.sh
    success_txt "Icon Pack Installed"
}

# Bibata-Modern-Ice mouse cursor pack
function install_mouse_cursor(){
    spinner "Downloading cursor theme" "wget -c $CURSOR_THEME --directory-prefix /tmp/mouse-cursor"
    cd /tmp/mouse-cursor
    tar -xJf Bibata-Modern-Ice.tar.xz
    cp -r Bibata-Modern-Ice ~/.local/share/icons/
    success_txt "Cursor Theme Installed"
}

# Install nerd fonts from provided list
function install_fonts(){
    if [[ ! -d /tmp/nerd-fonts/ ]];then
        mkdir /tmp/nerd-fonts/
    fi

    for font in "${FONTS[@]}";do
        spinner "Installing ${font} Nerd Font..."  "wget --directory-prefix ~/tmp/nerd-fonts/ -c ${GH}/ryanoasis/nerd-fonts/releases/download/v3.1.1/${font}.tar.xz -O - | tar -xJf - --directory /tmp/nerd-fonts/"
    cd /tmp/nerd-fonts/
    cp *.ttf *.otf ~/.local/share/fonts/
    done
    success_txt "Fonts Installed"
}

# By defaults installs catppuccin theme
function install_gtk_themes(){
    path=/tmp/gtk-themes
    spinner "Downloading ${GTK_THEME}" "wget --directory-prefix $path -c https://github.com/catppuccin/gtk/releases/download/v0.7.1/${GTK_THEME}.zip"
    cd $path
    unzip *.zip
    mkdir ~/.config/gtk-theme-backup
    mv ~/.config/{gtk-3.0,gtk-4.0} ~/.config/gtk-theme-backup
    cp $GTK_THEME/{gtk-3.0,gtk-4.0} -r ~/.config/
    success_txt "Installed GTK 3.0 & 4.0 Theme"
}

# For npm, pnpm. yan & bun stuff
function install_volta_sh(){
    spinner "Installing Volta.sh..." "curl https://get.volta.sh | bash"
    success_txt "Volta.sh Installed"
}

# Qt theme
function  install_kvantum_theme(){
    GH_RAW="https://raw.githubusercontent.com/catppuccin/Kvantum/main/src/Catppuccin-Mocha-Lavender/Catppuccin-Mocha-Lavender"
    THEME_DIR="/home/$USER/.config/Kvantum/Catppuccin-Mocha-Lavender/"

    dir_check $THEME_DIR
    spinner "Downloading Catppuccin Mocha Lavender" "wget -c "${GH_RAW}.kvconfig" "${GH_RAW}.svg" --directory-prefix $THEME_DIR" 
    printf "[General]\ntheme=Catppuccin-Mocha-Lavender" | tee /home/$USER/.config/Kvantum/kvantum.kvconfig &> /dev/null
    success_txt "Kvantum Theme Installed"
}

function main(){
    clear
    welcome_msg
    echo "⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯"
    echo ""
    echo "Proceed with $(gum style --foreground '#a6e3a1' 'Installation')?"
    conformation=$(gum choose {"YES","NO"})
    if [[ $conformation == "YES" ]];then
        icon_pack
        install_fonts
        install_gtk_themes
        install_kvantum_theme
        install_mouse_cursor
        install_volta_sh
        sddm_theme
    else 
        exit 0
    fi
}

if ! pacman -Qi $DEPENDENCIES > /dev/null ; then
    sudo pacman -S $DEPENDENCIES --needed 
    main
else
    main
fi

