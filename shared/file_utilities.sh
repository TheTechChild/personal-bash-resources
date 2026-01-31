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

# ---------------------------------------------------------------------------
# Backup manifest helpers
# ---------------------------------------------------------------------------

_pbr_resolve_path() {
    local raw_path="$1"
    echo "${raw_path/#\~/$HOME}"
}

_pbr_get_manifest_path() {
    local manifest="$PBR_DIR/extensions/backup-manifest.sh"
    if [[ -f "$manifest" ]]; then
        echo "$manifest"
    else
        echo ""
    fi
}

_pbr_platform_index() {
    case "$PBR_PLATFORM" in
        macos)        echo 1 ;;
        linux-arch)   echo 2 ;;
        linux-unknown) echo 2 ;;
        *)            echo 2 ;;
    esac
}

# ---------------------------------------------------------------------------
# backup-pbr-init
# ---------------------------------------------------------------------------

backup-pbr-init() {
    local example="$PBR_DIR/extensions/backup-manifest.sh.example"
    local target="$PBR_DIR/extensions/backup-manifest.sh"

    if [[ -f "$target" ]]; then
        echo "Manifest already exists at: $target"
        echo "Edit it to add or remove backup items."
        return 0
    fi

    if [[ ! -f "$example" ]]; then
        echo "Error: Example manifest not found at $example"
        return 1
    fi

    cp "$example" "$target"
    echo "Created backup manifest: $target"
    echo ""
    echo "Edit this file to specify which external folders to include in backups."
    echo "Uncomment entries or add your own in the format:"
    echo '    "label|macos_path|linux_path"'
}

# ---------------------------------------------------------------------------
# backup-pbr [--yolo]
# ---------------------------------------------------------------------------

backup-pbr() {
    local yolo=false
    if [[ "$1" == "--yolo" ]]; then
        yolo=true
    fi

    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local zip_file="$PBR_DIR/pbr_backup_$timestamp.zip"

    if [[ ! -d "$PBR_DIR/extensions" ]]; then
        echo "Error: Extensions directory not found at $PBR_DIR/extensions"
        return 1
    fi

    local tmp_stage
    tmp_stage=$(mktemp -d)

    echo "Preparing backup..."

    cp -R "$PBR_DIR/extensions" "$tmp_stage/extensions"
    find "$tmp_stage/extensions" -name ".DS_Store" -delete 2>/dev/null

    local has_externals=false
    local manifest
    manifest=$(_pbr_get_manifest_path)

    if [[ -n "$manifest" ]]; then
        source "$manifest"

        if [[ ${#PBR_BACKUP_ITEMS[@]} -gt 0 ]]; then
            local platform_idx
            platform_idx=$(_pbr_platform_index)

            for item in "${PBR_BACKUP_ITEMS[@]}"; do
                local label macos_path linux_path source_path
                IFS='|' read -r label macos_path linux_path <<< "$item"

                if [[ "$platform_idx" == "1" ]]; then
                    source_path=$(_pbr_resolve_path "$macos_path")
                else
                    source_path=$(_pbr_resolve_path "$linux_path")
                fi

                if [[ -d "$source_path" ]]; then
                    echo "  Including: $label ($source_path)"
                    mkdir -p "$tmp_stage/external/$label"
                    cp -R "$source_path/." "$tmp_stage/external/$label/"
                    find "$tmp_stage/external/$label" -name ".DS_Store" -delete 2>/dev/null
                    has_externals=true
                elif [[ -f "$source_path" ]]; then
                    echo "  Including: $label ($source_path)"
                    mkdir -p "$tmp_stage/external/$label"
                    cp "$source_path" "$tmp_stage/external/$label/"
                    has_externals=true
                else
                    echo "  Skipping:  $label ($source_path not found)"
                fi
            done
        fi
    fi

    echo ""
    echo "Creating archive..."
    pushd "$tmp_stage" > /dev/null
    zip -rq "$zip_file" .
    local zip_rc=$?
    popd > /dev/null
    rm -rf "$tmp_stage"

    if [[ $zip_rc -ne 0 ]]; then
        echo "Error: Failed to create archive"
        return 1
    fi

    if [[ "$yolo" == true ]]; then
        echo ""
        echo "Backup created (UNENCRYPTED): $zip_file"
        echo "WARNING: This backup is not encrypted. Do not store it in shared or public locations."
        return 0
    fi

    echo ""
    echo "================================================================"
    echo "  ENCRYPTION"
    echo "================================================================"
    echo ""
    echo "This backup will be encrypted with AES-256."
    if [[ "$has_externals" == true ]]; then
        echo "It contains external items (SSH keys, tokens, configs)."
    fi
    echo ""
    echo "You MUST remember the password you are about to set."
    echo "There is NO recovery if you forget it."
    echo ""
    read -rp "Press Enter to continue (or Ctrl+C to abort)..."
    echo ""

    local enc_file="${zip_file}.enc"

    openssl enc -aes-256-cbc -pbkdf2 -salt -in "$zip_file" -out "$enc_file"

    if [[ $? -ne 0 ]]; then
        echo "Error: Encryption failed"
        rm -f "$enc_file"
        return 1
    fi

    rm -f "$zip_file"

    echo ""
    echo "Encrypted backup created: $enc_file"
    echo "Remember your password — there is no recovery."
}

# ---------------------------------------------------------------------------
# restore-pbr <file>   (auto-detects .enc vs .zip)
# ---------------------------------------------------------------------------

restore-pbr() {
    local backup_file="$1"

    if [[ -z "$backup_file" ]]; then
        backup_file=$(find "$PBR_DIR" -maxdepth 1 \( -name "pbr_backup_*.zip.enc" -o -name "pbr_backup_*.zip" \) | sort -r | head -n 1)

        if [[ -z "$backup_file" ]]; then
            backup_file=$(find "$PBR_DIR" -maxdepth 1 -name "extensions_backup_*.zip" | sort -r | head -n 1)
        fi

        if [[ -z "$backup_file" ]]; then
            echo "Error: No backup files found in $PBR_DIR"
            echo "Usage: restore-pbr [path/to/backup]"
            return 1
        fi
    fi

    if [[ ! -f "$backup_file" ]]; then
        echo "Error: File not found: $backup_file"
        return 1
    fi

    echo "Found backup: $backup_file"

    local zip_to_extract="$backup_file"
    local decrypted_tmp=""

    if [[ "$backup_file" == *.enc ]]; then
        echo ""
        echo "This backup is encrypted. Enter your password to decrypt."
        echo ""

        decrypted_tmp=$(mktemp)
        openssl enc -d -aes-256-cbc -pbkdf2 -in "$backup_file" -out "$decrypted_tmp"

        if [[ $? -ne 0 ]]; then
            echo "Error: Decryption failed (wrong password?)"
            rm -f "$decrypted_tmp"
            return 1
        fi

        zip_to_extract="$decrypted_tmp"
        echo "Decrypted successfully."
    fi

    local tmp_restore
    tmp_restore=$(mktemp -d)

    unzip -qo "$zip_to_extract" -d "$tmp_restore"

    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to extract archive"
        rm -rf "$tmp_restore"
        [[ -n "$decrypted_tmp" ]] && rm -f "$decrypted_tmp"
        return 1
    fi

    [[ -n "$decrypted_tmp" ]] && rm -f "$decrypted_tmp"

    if [[ -d "$tmp_restore/extensions" ]]; then
        echo "Restoring extensions..."
        mkdir -p "$PBR_DIR/extensions"
        cp -R "$tmp_restore/extensions/." "$PBR_DIR/extensions/"
        echo "  -> $PBR_DIR/extensions/"
    fi

    if [[ -d "$tmp_restore/external" ]]; then
        local manifest="$tmp_restore/extensions/backup-manifest.sh"

        if [[ ! -f "$manifest" ]]; then
            manifest=$(_pbr_get_manifest_path)
        fi

        if [[ -z "$manifest" || ! -f "$manifest" ]]; then
            echo ""
            echo "WARNING: No backup manifest found. External items cannot be restored"
            echo "without a manifest to determine destination paths."
            echo "External items are preserved in: $tmp_restore/external/"
            echo "You will need to copy them manually."
            return 1
        fi

        source "$manifest"
        local platform_idx
        platform_idx=$(_pbr_platform_index)

        echo ""
        echo "Restoring external items..."

        for item in "${PBR_BACKUP_ITEMS[@]}"; do
            local label macos_path linux_path target_path
            IFS='|' read -r label macos_path linux_path <<< "$item"

            if [[ "$platform_idx" == "1" ]]; then
                target_path=$(_pbr_resolve_path "$macos_path")
            else
                target_path=$(_pbr_resolve_path "$linux_path")
            fi

            if [[ -d "$tmp_restore/external/$label" ]]; then
                mkdir -p "$target_path"
                cp -R "$tmp_restore/external/$label/." "$target_path/"
                echo "  -> $label: $target_path"

                if [[ "$label" == "ssh" ]]; then
                    chmod 700 "$target_path"
                    find "$target_path" -type f -name "id_*" ! -name "*.pub" -exec chmod 600 {} \;
                    find "$target_path" -type f -name "*.pub" -exec chmod 644 {} \;
                    [[ -f "$target_path/config" ]] && chmod 600 "$target_path/config"
                    echo "  -> Fixed SSH permissions (700/600/644)"
                fi
            else
                echo "  -> $label: not in backup (skipped)"
            fi
        done
    fi

    rm -rf "$tmp_restore"

    echo ""
    echo "Restore complete."
}

# Keep the old name as an alias for backwards compatibility
restore-pbr-extensions() {
    restore-pbr "$@"
}
