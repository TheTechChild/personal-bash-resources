#!/bin/bash

tch() {
    if [ -z "$1" ]; then
        echo "Usage: tch <filename> ... This function will create the file specified at the current location where the terminal is at"
        return 1
    fi

    local filename="$1"

    touch "$filename"

    code "$filename"
}

backup-pbr() {
    local timestamp=$(date +"%Y%m%d")
    local zip_file="$PBR_DIR/extensions_backup_$timestamp.zip"

    if [ ! -d "$PBR_DIR/extensions" ]; then
        echo "Error: Extensions directory not found at $PBR_DIR/extensions"
        return 1
    fi

    echo "Creating backup of extensions folder..."
    (cd "$PBR_DIR" && zip -r "$zip_file" extensions/ -x "extensions/.DS_Store")

    if [ $? -eq 0 ]; then
        echo "Backup created successfully: $zip_file"
    else
        echo "Error: Failed to create backup"
        return 1
    fi
}

restore-pbr-extensions() {
    local latest_backup=$(find "$PBR_DIR" -maxdepth 1 -name "extensions_backup_*.zip" | sort -r | head -n 1)

    if [ -z "$latest_backup" ]; then
        echo "Error: No backup files found in $PBR_DIR"
        echo "Backup files should have the format: extensions_backup_YYYYMMDD.zip"
        return 1
    fi

    echo "Found latest backup: $latest_backup"
    echo "Restoring extensions folder..."
    unzip -qo "$latest_backup" -d "$PBR_DIR"

    if [ $? -eq 0 ]; then
        echo "Extensions folder restored successfully."
    else
        echo "Error: Failed to extract the zip file."
        return 1
    fi
}
