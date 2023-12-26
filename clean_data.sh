#!/bin/bash
set -e

data_dir=$(find /data -maxdepth 1 -type d \( -name "fe*" -o -name "be*" \) | xargs)

if [ -z "$data_dir" ]; then
    echo "No doris data directory found."
    exit 1
fi

echo "Found doris data directory: $data_dir"
read -r -p "Do you want to delete them? [y/N] " answer

if [[ "$answer" =~ ^[Yy]$ ]]; then
    echo "Deleting doris data directory: $data_dir"
    echo $data_dir | xargs sudo rm -r
fi
