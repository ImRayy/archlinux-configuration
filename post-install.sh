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
    gum spin --spinner="dot" -- bash -c "${1}"
}

function welcome_msg() {
    echo "Post installation script to install $(gum style --italic --foreground '#b4befe' 'SDDM theme, icon & mouse cursor theme, fonts ') etc."
}

# Downloads sddm-sugar-candy and replaces default background 
# with chosen one
function SDDM_THEME(){
    git clone $SDDM_THEME /tmp/sddm-sugar-candy
    cd /tmp/sddm-sugar-candy/Backgrounds
    rm Mountain.jpg
    curl $SDDM_BACKGROUND -o Mountain.jpg
    sudo cp -R  /tmp/sddm-sugar-candy  /usr/share/sddm/themes/
    echo "[Theme]
    Current=sddm-sugar-candy" | sudo tee -a /etc/sddm.conf.d/sddm.conf
}

# Downloads tele-circle-icon pack and run it's own install script
function icon_pack(){
    git clone $ICON_PACK /tmp/icon-pack/
    cd /tmp/icon-pack
    bash install.sh
}

# Bibata-Modern-Ice mouse cursor pack
function mouse_cursor_install(){
    wget -c $CURSOR_THEME --directory-prefix /tmp/mouse-cursor
    cd /tmp/mouse-cursor
    tar -xJf Bibata-Modern-Ice.tar.xz
    cp -r Bibata-Modern-Ice ~/.local/share/icons/
}

# Install nerd fonts from provided list
function install_fonts(){
    if [[ ! -d /tmp/nerd-fonts/ ]];then
        mkdir /tmp/nerd-FONTS/
    fi

    for font in "${FONTS[@]}";do
        gum spin --spinner="dot" --title="Installing ${font} Nerd Font..." -- bash -c  "wget --directory-prefix ~/Downloads/Misc/ -c https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/${font}.tar.xz -O - | tar -xJf - --directory /tmp/nerd-fonts/"
    cd /tmp/nerd-fonts/
    cp *.ttf ~/.local/share/fonts/
    done
}

# By defaults installs catppuccin theme
function install_gtk_themes(){
    path=/tmp/gtk-themes
    gum spin --spinner="dot" --title="Downloading ${GTK_THEME}"  -- bash -c "wget --directory-prefix $path -c https://github.com/catppuccin/gtk/releases/download/v0.7.1/${GTK_THEME}.zip"
    cd $path
    unzip *.zip
    mkdir ~/.config/gtk-theme-backup
    mv ~/.config/{gtk-3.0,gtk-4.0} ~/.config/gtk-theme-backup
    cp $GTK_THEME/{gtk-3.0,gtk-4.0} -r ~/.config/
}

# For npm, pnpm. yan & bun stuff
function install_volta_sh(){
    gum spin --spinner="dotr" --title="Installing Volta.sh..." -- bash -c "curl https://get.volta.sh | bash"
}

# Qt theme
function  install_kvantum_theme(){
    GH_RAW="https://raw.githubusercontent.com/catppuccin/Kvantum/main/src/Catppuccin-Mocha-Lavender/Catppuccin-Mocha-Lavender"
    THEME_DIR="/home/$USER/.config/Kvantum/Catppuccin-Mocha-Lavender/"

    dir_check $THEME_DIR
    spinner  "wget -c "${GH_RAW}.kvconfig" "${GH_RAW}.svg" --directory-prefix $THEME_DIR"
    printf "[General]\ntheme=Catppuccin-Mocha-Lavender" | tee /home/$USER/.config/Kvantum/kvantum.kvconfig &> /dev/null
}

if ! pacman -Qi $DEPENDENCIES > /dev/null ; then
    sudo pacman -S $DEPENDENCIES --needed
fi

install_kvantum_theme
