#!/bin/sh
# Downloads all images from twitter post

if [ $# -eq 0 ]
then
    echo "Usage: $0 *twitter post*"
    exit 1
fi

# Extract highest quality images from post
pics=$(curl -s "$1" | grep 'property=\"og:image\"' | awk '{print $3}'| sed -e 's/content="//' -e 's/:large">/?name=orig/' | tr '\n' ' ')

# Download that shit (this fails if you put quotes around the variable, dont ask me why)
curl --fail --remote-time --remote-name-all $pics

# Rename messed up twitter filenames
for f in *?name=orig; do
    mv "$f" "${f%?name=orig}"
done