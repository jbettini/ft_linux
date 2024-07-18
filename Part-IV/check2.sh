# eudev: systemctl status systemd-udevd
# sysklogd: journald / journactl
# sysvinit: systemd

# time zone data: timedatectl in systemd 

#!/bin/bash

# Vérifiez que le fichier a été passé en argument
if [ -z "$1" ]; then
    echo "Usage: $0 <file>"
    exit 1
fi

# Définir les chemins spécifiques et les binaires pour certains paquets
declare -A custom_paths
custom_paths=(
    ["iana-etc"]="/etc/protocols /etc/services"
    ["expat"]="/usr/share/doc/expat-2.6.0 /usr/bin/xmlwf /usr/share/man/man1/xmlwf.1"
    ["findutils"]="/usr/bin/find /usr/share/man/mann/find.n /usr/share/man/man1/find.1 /usr/share/info/find.info-1 /usr/share/info/find.info /usr/share/info/find.info-2 /usr/bin/locate /usr/share/man/man1/locate.1 /usr/bin/updatedb /usr/share/man/man1/updatedb.1 /usr/bin/xargs /usr/share/man/man1/xargs.1 /var/lib/locate"
    ["kbd"]="/usr/share/consolefonts /usr/share/consoletrans /usr/share/keymaps /usr/share/doc/kbd-2.6.4 /usr/share/unimaps"
)

declare -A custom_binaries
custom_binaries=(
    ["tcl"]="tclsh8.6 tclsh"
    ["psmisc"]="fuser killall peekfd prtstat pslog pstree pstree.x11"
)

# Fonction pour vérifier les chemins personnalisés
check_custom_paths() {
    local paths=$1
    for path in $paths; do
        if [[ ! -e "$path" ]]; then
            return 1
        fi
    done
    return 0
}

# Fonction pour vérifier les binaires personnalisés
check_custom_binaries() {
    local binaries=$1
    for binary in $binaries; do
        result=$(whereis "$binary")
        if [[ "$result" == "$binary:"* ]]; then
            return 1
        fi
    done
    return 0
}

# Lisez chaque ligne du fichier et utilisez `whereis` ou vérifiez les chemins/binaries spécifiques
while IFS= read -r line; do
    paths_ok=true
    binaries_ok=true

    if [[ -n "${custom_paths[$line]}" ]]; then
        if ! check_custom_paths "${custom_paths[$line]}"; then
            paths_ok=false
        fi
    fi

    if [[ -n "${custom_binaries[$line]}" ]]; then
        if ! check_custom_binaries "${custom_binaries[$line]}"; then
            binaries_ok=false
        fi
    fi

    if [[ "$paths_ok" = true && "$binaries_ok" = true ]]; then
        echo "$line: ok"
    else
        echo "$line: not find"
    fi
done < "$1"
