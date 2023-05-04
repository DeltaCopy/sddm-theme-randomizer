#!/usr/bin/env sh

# call this script inside
# /usr/share/sddm/scripts/Xsetup
#!/bin/sh
# Xsetup - run as root before the login dialog appears
# <add full path to script here>


SDDM_CONF="/etc/sddm.conf.d/kde_settings.conf"
SDDM_THEMES="/usr/share/sddm/themes"
THEMES=()

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "                  SDDM Theme Randomizer             "
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++"

function pre_checks {
    # pre-checks

    test $(whoami) != "root" && echo "[ERROR] Root user required to change SDDM themes" && exit 1

    test ! -s "$SDDM_CONF" && echo "[ERROR] $SDDM_CONF does not exist/is empty" && exit 1 || echo "[INFO] $SDDM_CONF exists"
    test ! -d "$SDDM_THEMES" && echo "[ERROR] $SDDM_THEMES does not exist" && exit 1 || echo "[INFO] $SDDM_THEMES exists"
}

function setup {
    # get the themes from the directory store in an array

    for theme in $(ls "$SDDM_THEMES"); do
        THEMES+=($theme)
    done
    # check there is something stored
    if [ "${#THEMES[@]}" -gt 0 ]; then
        echo "[INFO] Stored "${#THEMES[@]}" themes"
    else
        echo "[ERROR] Failed to store themes."
        exit 1
    fi
}

function apply {
    # get the current theme
    current_theme=$(cat "$SDDM_CONF" | grep -w Current | awk -F'Current=' {'print $2'})

    echo "[INFO] Current theme = $current_theme"

    # get a random theme from the array
    len="${#THEMES[@]}"
    random=$[ $RANDOM % $len + 0 ]

    random_theme=${THEMES[$random]}

    # make sure we actually have a different theme
    while [ "$current_theme" == "$random_theme" ]; do
        random=$[ $RANDOM % $len + 0 ]
        random_theme=${THEMES[$random]}
    done

    echo "[INFO] Random theme = $random_theme"

    sed -i.bak -e "s/${current_theme}/${random_theme}/g" $SDDM_CONF
}

pre_checks
setup
apply
