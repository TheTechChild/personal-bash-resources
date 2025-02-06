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
