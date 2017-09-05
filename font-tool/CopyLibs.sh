#!/bin/bash

app=$1

depin=/usr/local/
depout=$(dirname "$app")

rm -rf "$depout/*.dylib"

function copy_deps {
    local master=$1
    local master_src=$2
    local deps=`otool -L "$master" | awk 'NR>1' | cut -d ' ' -f1`

    for dep in $deps; do
        if [ "$dep" == "$master" ]; then
            continue
        fi

        if [[ "$dep" == @loader_path/* ]]; then
            dep=$(dirname "$master_src")/$(basename "$dep")
        fi
        
        if [[ "$dep" == ${depin}* ]]; then
            local file_name=$(basename "$dep")
            local new_path=$depout/$file_name
            echo Copying "$dep" to "$new_path"
            cp -rf "$dep" "$new_path"
            chmod +w "$new_path"
            install_name_tool -id "@rpath/$file_name" "$new_path"
            install_name_tool -change "$dep" "@rpath/$file_name" "$master"
            copy_deps "$new_path" "$dep"
        fi
    done
}

copy_deps "$app"
install_name_tool -delete_rpath "@loader_path" "$app" &>/dev/null
install_name_tool -add_rpath "@loader_path" "$app"
