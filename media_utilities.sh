# Media Utilities
convert_webp_to_jpg() {
  if ! command -v ffmpeg &>/dev/null; then
    echo "Error: ffmpeg is not installed or not in your PATH."
    return 1
  fi

  if [ $# -ne 2 ]; then
    echo "Usage: convert_webp_to_jpg input.webp output.jpg"
    return 1
  fi

  local output_file="$1"
  local output_file="$2"

  ffmpeg -i "$input_file" "$output_file"
}

embed_album_art() {
    # Check if ffmpeg is installed
    if ! command -v ffmpeg &> /dev/null; then
        echo "Error: ffmpeg is not installed or not in your PATH."
        return 1
    fi

    # Check if the correct number of arguments is provided
    if [ $# -ne 2 ]; then
        echo "Usage: embed_album_art image.jpg /path/to/mp3/directory"
        return 1
    fi

    local image_path="$1"
    local mp3_dir="$2"

    # Check if the image file exists
    if [ ! -f "$image_path" ]; then
        echo "Error: Image file '$image_path' does not exist."
        return 1
    fi

    # Check if the directory exists
    if [ ! -d "$mp3_dir" ]; then
        echo "Error: Directory '$mp3_dir' does not exist."
        return 1
    fi

    # Loop through each MP3 file in the directory
    for mp3file in "$mp3_dir"/*.mp3; do
        # Check if there are any mp3 files in the directory
        if [ ! -e "$mp3file" ]; then
            echo "No MP3 files found in the directory."
            return 1
        fi

        # Temporary output file
        local temp_output="${mp3file%.mp3}_temp.mp3"
        
        # Embed the image as album art
        ffmpeg -i "$mp3file" -i "$image_path" -map 0 -map 1 -c copy -id3v2_version 3 -metadata:s:v title="Album cover" -metadata:s:v comment="Cover (front)" "$temp_output"

        # Check if ffmpeg succeeded
        if [ $? -eq 0 ]; then
            # Remove the original file and rename the new file
            mv "$temp_output" "$mp3file"
        else
            echo "Error processing file: $mp3file"
            rm -f "$temp_output"
        fi
    done
}