#!/bin/bash

# Function for uploading files
uploadFile() {
  if [ $# -gt 0 ]; then
    for file_path in "$@"; do
      if [[ "$file_path" == -* ]]; then
        continue  # Skip files that start with a hyphen (options)
      fi
      response=$(curl --upload-file "$file_path" https://free.keep.sh 2> /dev/null)
      code=$?
      if [ "$code" -eq 0 ]; then
        url="$response"
        echo "$response"
        echo "Uploading $file_path"
        echo "Transfer File URL: $url"
      else
        echo "Error uploading $file_path"
      fi
    done
  else
    echo "Error: Missing file path(s) for upload."
    exit 1
  fi
}

# Function for single file download with progress bar
singleDownload() {
  local target_directory="$1"
  local filename="$2"
  local url="https://free.keep.sh/$filename"
  echo "Downloading $url"
  # Use curl with -# option to show progress bar
  curl -# -L "$url" > "$target_directory/$filename"  # Save the file in the specified directory
  return $?
}

# Function to print download response
printDownloadResponse() {
  local filename="$1"
  local result="$2"
  if [ "$result" -eq 0 ]; then
    echo "Success! Downloaded $filename"
  else
    echo "Error downloading $filename"
  fi
}

# Function to display script version
displayVersion() {
  echo "0.0.1"
}

# Initialize flags and target directory
show_help=false
download=false
target_directory=""

# Parse command line arguments
while getopts ":dhv" opt; do
  case $opt in
    d)
      download=true
      ;;
    h)
      show_help=true
      ;;
    v)
      displayVersion  # Display script version when -v is provided
      exit 0
      ;;
    \?)
      echo "Invalid option: -$OPTARG"
      exit 1
      ;;
  esac
done

# Shift the processed options out of the argument list
shift "$((OPTIND-1))"

# Check if the -d flag is provided for downloading
if $download; then
  if [ $# -lt 2 ]; then
    echo "Error: Missing target directory or file name(s) for download."
    exit 1
  fi
  target_directory="$1"
  shift  # Remove the target directory argument from the list
  for filename in "$@"; do
    singleDownload "$target_directory" "$filename"
    printDownloadResponse "$filename" $?
  done
else
  if $show_help; then
    echo "Usage: $0 [-d] [-h] [-v] <file1> [file2] ..."
    echo "  -d  Download files instead of uploading."
    echo "  -h  Show this help message."
    echo "  -v  Display script version."
    exit 0
  fi
  uploadFile "$@"
fi
