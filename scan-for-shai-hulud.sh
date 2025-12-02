#!/bin/bash

SEARCH_DIR=$1

if [ -z "$SEARCH_DIR" ]; then
    SEARCH_DIR="$HOME"
fi

progress-bar() {
    local progress=$1
    local package_len=$2
    local perc_done=$((progress * 100 / package_len))
echo -ne "\rProcessing file $progress out of $package_len [$perc_done%]"
}

echo "DISCLAIMER: This script compares package.json files found on your computer to a list of packages known to be affected by the Shai-Hulud 2.0 attack on NPM."
echo "It is possible that this script miss packages and that you may be affected even if the results of this scripts says that no infected packages were found."
echo "This script does not address any affected packages or alter any files."
echo
echo "Extracting package.json files"
INFECTED_PACKAGES=$(awk '{print $1}' "shai-hulud-2-packages.csv"| sed 's/,=//g' | tr -d ' ')


PACKAGE_FILES=()

while IFS= read -r -d '' package; do
    PACKAGE_FILES+=("$package")
done < <(find "$SEARCH_DIR" -name package.json -print0 2>/dev/null)


NR_OF_PACKAGES=${#PACKAGE_FILES[@]}
echo
progress=1
MATCHES=()

for package in "${PACKAGE_FILES[@]}"; do
    progress-bar $progress "$NR_OF_PACKAGES"
    package_processed=$(jq '.dependencies, .devDependencies' "$package" 2>/dev/null)

    USED_PACKAGE=$(grep -w "$INFECTED_PACKAGES" <<< "$package_processed" | tr -d " ")

    if [[ -n $USED_PACKAGE ]]; then
        grep "$USED_PACKAGE" ./shai-hulud-2-packages.csv

        MATCHES+=("--- $package ---")
        for pkg in $USED_PACKAGE; do
            infected=$(grep "$( echo "${pkg//\"/}" | sed 's/:.*//g')" ./shai-hulud-2-packages.csv)
            if [[ -z $infected ]]; then
                infected="No package with this exact name found"
            fi
            MATCHES+=("Package Used: $(echo "${pkg//,/}" | sed 's/"//g') - Infected Package: ${infected//,=/:}")
        done
        MATCHES+=("")
    fi
    ((progress++))
done

if [ ! ${#MATCHES[@]} -eq 0  ]; then
    echo -ne "\n\nInspect versions of packages below\n"
    echo '"Package Used" is the package found on your computer. "Infected Package" is the package listed as affected by the Shai-Hulud 2.0 attack.'
    echo "If the versions do not match you should not be affected. However, make sure your versions ar locked so you dont pull down infected versions."
    echo -ne "\nPossible matches:\n"

    for match in "${MATCHES[@]}"; do
        echo "$match"
    done
else
    echo -ne "\n\nNo infected packages found\n"
fi
