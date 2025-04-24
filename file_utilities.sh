# Functions to manipulate files
tch() {
    # Check if a filename is provided
    if [ -z "$1" ]; then
        echo "Usage: tch <filename> ... This function will create the file specified at the current location where the terminal is at"
        return 1
    fi

    local filename="$1"

    # Create the file
    touch "$filename"

    # Open the file using the 'cursor' command
    cursor "$filename"
}

# Function to backup extensions folder
backup-pbr() {
    local timestamp=$(date +"%Y%m%d")
    local zip_file="$PBR_DIR/extensions_backup_$timestamp.zip"
    
    # Check if extensions directory exists
    if [ ! -d "$PBR_DIR/extensions" ]; then
        echo "Error: Extensions directory not found at $PBR_DIR/extensions"
        return 1
    fi
    
    # Create zip file
    echo "Creating backup of extensions folder..."
    zip -r "$zip_file" -j "$PBR_DIR/extensions"
    
    if [ $? -eq 0 ]; then
        echo "Backup created successfully: $zip_file"
    else
        echo "Error: Failed to create backup"
        return 1
    fi
}

restore-pbr-extensions() {
    local temp_dir="/tmp/pbr_restore_temp"
    
    # Find the latest backup file based on the date in the filename
    local latest_backup=$(find "$PBR_DIR" -name "extensions_backup_*.zip" | sort -r | head -n 1)
    
    # Check if any backup files were found
    if [ -z "$latest_backup" ]; then
        echo "Error: No backup files found in $PBR_DIR"
        echo "Backup files should have the format: extensions_backup_YYYYMMDD.zip"
        return 1
    fi
    
    echo "Found latest backup: $latest_backup"
    
    # Create temporary directory for extraction
    mkdir -p "$temp_dir"
    
    # Unzip the backup file to the temporary directory
    echo "Extracting backup file..."
    unzip -q "$latest_backup" -d "$temp_dir"
    
    if [ $? -ne 0 ]; then
        echo "Error: Failed to extract the zip file."
        rm -rf "$temp_dir"
        return 1
    fi
    
    # Copy the contents to the extensions folder
    echo "Restoring extensions folder..."
    cp -R "$temp_dir/"* "$PBR_DIR/extensions"
    
    if [ $? -eq 0 ]; then
        echo "Extensions folder restored successfully."
    else
        echo "Error: Failed to restore extensions folder."
        rm -rf "$temp_dir"
        return 1
    fi
    
    # Clean up temporary directory
    rm -rf "$temp_dir"
    echo "Restore operation completed."
}
