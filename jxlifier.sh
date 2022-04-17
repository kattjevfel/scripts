#!/bin/bash
IFS=$'\n'

if [ $# -eq 0 ]; then
	echo 'I feast on images and you'\''ve left me hungry!'
	exit
fi

# Colours!
cres='\033[0m'    # reset
cred='\033[0;31m' # red
cyel='\033[0;33m' # yellow
cgrn='\033[0;32m' # green

echoerr() {
	echo >&2 -e "ERROR: ${cred}${*}${cres}"
}

for file in "$@"; do
	# Filename only
	shortfile=${file##*/}
	# Dir only
	directory=${file%/*}
	# fuck basename
	basename=${file%.*}
	# mime-type
	mimetype="$(file -b --mime-type "$file")"

	# Make sure file exists and is a picture
	if ! [[ -f $file ]] || ! [ "$(echo "$mimetype" | cut -d/ -f1)" = image ]; then
		echoerr "$shortfile is not a valid image!"
		continue
	fi

	# Check that file is not already converted
	if [[ -f $basename.jxl ]]; then
		echoerr "$shortfile was already converted!"
		continue
	fi

	# Workaround for imagemagick not supporting animated jxl's
	if identify "$file" | grep -q '\[1\]'; then
		echoerr "$shortfile is an animation which is not supported!"
		continue
	fi

	# Filesize before converting in bytes & human readable
	sizepre="$(stat -c '%s' "$file" 2>/dev/null)"
	sizeprehuman=$(numfmt --to=iec-i --suffix=B --format='%.1f' "$sizepre" 2>/dev/null)

	# Print current file (with path) being processed + size in human readable
	echo -n "Converting $file ($sizeprehuman)... "

	# Command to perform conversion
	# Use cjxl for all its supported formats, mogrify for anything else
	if [ "$mimetype" = "image/png" ] || [ "$mimetype" = "image/apng" ] || [ "$mimetype" = "image/gif" ] || [ "$mimetype" = "image/jpeg" ] || [ "$mimetype" = "image/x-exr" ] || [ "$mimetype" = "image/x-portable-bitmap" ] || [ "$mimetype" = "image/x-portable-graymap" ] || [ "$mimetype" = "image/x-portable-pixmap" ] || [ "$mimetype" = "image/x-portable-anymap" ]; then
		convert_command=(cjxl -e 9 "$file" "$basename".jxl)
	else
		convert_command=(mogrify -format jxl -define jxl:effort=9 "$file")
	fi

	if ERROR=$({ "${convert_command[@]}"; } 2>&1); then
		# Filesize after converting in bytes & human readable
		sizesuf="$(stat -c '%s' "$basename".jxl)"
		sizesufhuman=$(numfmt --to=iec-i --suffix=B --format='%.1f' "$sizesuf")

		# Give up if bigger than source
		if (("$sizesuf" > "$sizepre")); then
			echo >&2 -e "${cyel}done, but ${shortfile%.*}.jxl is bigger than the source, deleting output!${cres}"
			rm "$basename.jxl"
			continue
		fi

		# Show off fancy stats!
		echo -e "done! -> ${cgrn}${shortfile%.*}.jxl ($sizesufhuman, $(awk "BEGIN {print $sizesuf/$sizepre*100}")% of original size)${cres}"

		# Delete original
		rm "$file"
	else
		echoerr "${ERROR/$directory\//}"
		continue
	fi
done
