#!/bin/bash

# Vérifiez que le fichier a été passé en argument
if [ -z "$1" ]; then
    echo "Usage: $0 <file>"
    exit 1
fi

# Lisez chaque ligne du fichier et utilisez `whereis`
while IFS= read -r line; do
    result=$(whereis "$line")
    # Vérifiez si le résultat contient un chemin
    if [[ "$result" == *"/"* ]]; then
        echo "$line: ok"
    else
        echo "$line: not find"
    fi
done < "$1"

