#!/bin/bash

# Function to add line to .bashrc only if it doesn't already exist
add_to_bashrc() {
    local line="$1"
    if ! grep -Fxq "$line" ~/.bashrc; then
        echo "$line" >> ~/.bashrc
        echo "Added: $line"
    else
        echo "Already exists: $line"
    fi
}

# Add configurations to .bashrc
add_to_bashrc "alias c='clear'"
add_to_bashrc "stty intr ^E"

echo ""
echo "To apply changes to your current shell, run:"
echo "source ~/.bashrc"
echo ""
echo "Or simply open a new terminal session."