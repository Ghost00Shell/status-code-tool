#!/bin/bash

# Set the ASCII art string
ascii_art="
     _        _                             _      
    | |      | |                           | |     
 ___| |_ __ _| |_ _   _ ___    ___ ___   __| | ___ 
/ __| __/ _  | __| | | / __|  / __/ _ \ / _  |/ _ |
\__ \ || (_| | |_| |_| \__ \ | (_| (_) | (_| |  __/
|___/\__\__ _|\__|\__ _|___/  \___\___/ \__ _|\___|

                                             𝕓𝕪:𝕕𝕚𝕒𝕓𝕝𝕠 
                                                   "

# Print the ASCII art string to the terminal
echo -e "$ascii_art"

# Function to display help
function display_help {
    echo "Usage: $0 [OPTIONS]... [FILE]..."
    echo "Execute commands on a file and optionally save output to another file."
    echo ""
    echo "Options:"
    echo "-h: Display this help message"
    echo "-o: Specify output file"
}

# Parse command-line arguments
while getopts ":ho:" opt; do
  case ${opt} in
    h )
      display_help
      exit 0
      ;;
    o )
      output_file=$OPTARG
      ;;
    \? )
      echo "Invalid Option: -$OPTARG" 1>&2
      exit 1
      ;;
    : )
      echo "Invalid Option: -$OPTARG requires an argument" 1>&2
      exit 1
      ;;
  esac
done
shift $((OPTIND -1))

# Check if file argument is provided
if [ $# -eq 0 ]; then
    echo "Error: No input file provided. Use -h for help."
    exit 1
fi

input_file=$1

# Check if an output file was provided
if [ $# -eq 3 ] && [ "$2" == "-o" ]; then
  output_file="$3"
fi

# Check if the provided file exists
if [ ! -f "$input_file" ]; then
  echo "File not found: $input_file"
  exit 1
fi

# Execute commands and save output to temporary file
temp_file=$(mktemp)
xargs -I{} echo https://{}/ < $input_file | while read LINE; do
  curl -o /dev/null --silent --head --write-out "%{http_code} $LINE\n" "$LINE"
done > $temp_file

# Print the output to the terminal and, if specified, save it to an output file.
cat $temp_file

if [ -n "$output_file" ]; then
    cat $temp_file > $output_file
    echo "Output saved to: $output_file"
fi

# Remove temporary file
rm $temp_file

exit 0
